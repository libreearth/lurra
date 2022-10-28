defmodule Lurra.ObserverConnectors.Mqtt do
  use GenServer

  alias Lurra.Monitoring
  alias Lurra.Events


  def init(state) do
    emqtt_opts = Application.get_env(:lurra, :emqtt)
    {:ok, pid} = :emqtt.start_link(emqtt_opts)
    {:ok, _} = :emqtt.connect(pid)
    # Listen reports
    {:ok, _, _} = :emqtt.subscribe(pid, "reports/#")
    {:ok, state}
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_info({:publish, %{payload: payload }}, state) do
    #send({epoch, value, device_id, sensor })

    with {:ok, %{"uuid" => device_id, "time" => time} = message} <- Jason.decode(payload),
          observer <- Monitoring.get_observer_by_device_id(device_id)

    do
      for {type, value } <- Map.drop(message, ["uuid", "time"]) do
        case Monitoring.get_sensor_by_type(type) do
          nil -> nil
          sensor ->
            Events.create_event_and_broadcast(to_string(value), observer.device_id, sensor, time * 1000)
        end
      end

      #uuid, time, 6 - temp, 3 - humidity, 1 - water
         #Events.create_event_and_broadcast(value, device_id, sensor, epoch)
    else
      error -> error
    end

    {:noreply, state}
  end
end
