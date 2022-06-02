defmodule Lurra.Triggers.Server do
  use GenServer

  alias LurraWeb.Endpoint
  alias Lurra.Triggers.Trigger
  alias Lurra.Triggers

  @events_topic "events"

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Endpoint.subscribe(@events_topic)
    {
      :ok,
      {build_trigger_maps(), %{}}
    }
  end

  def update(), do: GenServer.cast(__MODULE__, :update)

  def handle_cast(:update, {_triggers, results}) do
    {
      :noreply,
      {build_trigger_maps(), results}
    }
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "event_created", payload: measurement, topic: @events_topic}, {triggers, results}) do
    updated_results = check_triggers(measurement, triggers, results)
    {:noreply, {triggers, updated_results}}
  end

  defp build_trigger_maps() do
    build_trigger_maps(Triggers.list_triggers(), %{})
  end

  defp build_trigger_maps([], map), do: map
  defp build_trigger_maps([ %Trigger{device_id: device_id, sensor_type: sensor_type} = trigger | rest_triggers], map) do
    trigger_list = Map.get(map, {device_id, sensor_type}, [])
    build_trigger_maps(rest_triggers, Map.put(map, {device_id, sensor_type}, [trigger | trigger_list]))
  end

  defp check_triggers(%{device_id: device_id, payload: payload, type: sensor_type}, triggers, results) do
    triggers_of_sensor =  Map.get(triggers, {device_id, sensor_type}, [])
    {triggers_to_run, triggers_discarded} = Lurra.Utils.Enum.filter_split(triggers_of_sensor, fn trigger -> Lurra.Triggers.Rule.check_rule(trigger.rule, payload) end)

    run_triggers(triggers_to_run, results, payload)

    results
    |> register_triggers(triggers_to_run, true)
    |> register_triggers(triggers_discarded, false)
  end

  defp register_triggers(results, triggers, value) do
    for trigger <- triggers, into: results do
      {trigger.id, value}
    end
  end

  defp run_triggers(triggers, results, payload) do
    triggers
    |> Enum.filter(fn trigger -> not Map.get(results, trigger.id, false) end)
    |> Enum.each(fn trigger -> Lurra.Triggers.Action.run(trigger, payload) end)
  end
end
