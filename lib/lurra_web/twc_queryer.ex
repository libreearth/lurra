defmodule LurraWeb.TwcQueryer do
  use GenServer

  alias Lurra.Monitoring
  alias Lurra.Events

  @ten_minutes 1000*60*10

  def init(state) do
    Process.send_after(self(), :tick, 1000)
    {:ok, state}
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_info(:tick, info) do
    gather_info()
    Process.send_after(self(), :tick, @ten_minutes)
    {:noreply, info}
  end

  defp gather_info() do
    observers = Monitoring.list_observers_by_type("weather.com")
    for observer <- observers do
      spawn( fn ->
        case request_weather_com(observer.device_id, observer.api_key) do
          {:ok, info} ->
            send_info(observer, info)
          _ ->
            nil
        end
      end)
    end

  end

  defp send_info(observer, %{"observations" => [%{"epoch" => epoch_secs} = info|_]}) do
    epoch = epoch_secs * 1000
    for sensor <- observer.sensors do
      get_sensor_value(info, sensor, observer.device_id, epoch)
      |> send()
    end
  end

  defp send_info(_observer, _info) do
    nil
  end

  defp request_weather_com(device_id, api_key) do
    with {:ok, request} <- HTTPoison.get("https://api.weather.com/v2/pws/observations/current?stationId=#{device_id}&format=json&units=m&apiKey=#{api_key}&numericPrecision=decimal"),
         {:ok, req_map} <- Jason.decode(request.body) do
      {:ok, req_map} |> IO.inspect
    else
      error ->
        IO.inspect error
        error
    end
  end

  defp get_sensor_value(info, sensor, device_id, epoch) do
    case sensor_value(info, sensor.field_name) do
      nil -> nil
      value -> {epoch, value, device_id, sensor}
    end
  end

  defp sensor_value(info, field_name) do
    case info[field_name] do
      nil ->
        case info["metric"] do
          nil -> nil
          metric -> metric[field_name]
        end
      value -> value
    end
  end

  defp send({epoch, value, device_id, sensor }) do
    Events.create_event_and_broadcast(value, device_id, sensor, epoch)
  end
end
