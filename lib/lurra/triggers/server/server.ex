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
    create_ets_tables()
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

  defp create_ets_tables() do
    :ets.new(:actions, [:set, :protected, :named_table])
  end

  defp check_triggers(%{device_id: device_id, payload: payload, type: sensor_type}, triggers, results) do
    triggers_of_sensor =  Map.get(triggers, {device_id, sensor_type}, [])
    {triggers_to_run, triggers_discarded} = Lurra.Utils.Enum.filter_split(triggers_of_sensor, fn trigger -> Lurra.Triggers.Rule.check_rule(trigger.rule, payload) end)

    time = :os.system_time(:millisecond)
    registered_results =
      results
      |> register_triggers_to_run(triggers_to_run, time)
      |> register_triggers_discarded(triggers_discarded)

    run_triggers(triggers_to_run, registered_results, time, payload)
    registered_results
  end

  defp register_triggers_to_run(results, triggers, time) do
    for trigger <- triggers, into: results do
      case Map.get(results, trigger.id) do
        nil -> {trigger.id, %{value: true, last_true: time}}
        %{value: false} -> {trigger.id, %{value: true, last_true: time}}
        other -> {trigger.id, other}
      end
    end
  end

  defp register_triggers_discarded(results, triggers) do
    for trigger <- triggers, into: results do
      case Map.get(results, trigger.id) do
        nil ->  {trigger.id, %{value: false, last_true: 0}}
        %{last_true: last_true} -> {trigger.id, %{value: false, last_true: last_true}}
      end
    end
  end

  defp run_triggers(triggers, results, time, payload) do
    triggers
    |> Enum.map(fn trigger -> {trigger.id, Lurra.Triggers.Action.run(trigger, Map.get(results, trigger.id), time, payload)} end)
  end
end
