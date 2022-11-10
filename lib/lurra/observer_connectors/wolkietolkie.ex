defmodule Lurra.ObserverConnectors.Wolkietolkie do
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
    observers = Monitoring.list_observers_by_type("Wolkie Tolkie")
    for observer <- observers do
      spawn( fn ->
        case request_wolkie_tolkie(observer.device_id, observer.api_key) do
          {:ok, info} ->
            send_info(observer, info)
          _ ->
            nil
        end
      end)
    end

  end

  defp send_info(_observer, nil) do
    nil
  end

  defp send_info(_observer, "") do
    nil
  end

  defp send_info(observer, info_csv) do
    csv_splitted = String.split(info_csv, "\n") |> Enum.filter(fn line -> line != "" end)
    header = List.first(csv_splitted) |> String.split(";")
    [time | values] = List.last(csv_splitted) |> String.split(";")
    with  tz <- String.trim(observer.timezone || ""),
          {:ok, naive} <- NaiveDateTime.from_iso8601(time<>":00"),
          {:ok, datetime} <- DateTime.from_naive(naive, tz, Timex.Timezone.Database),
          epoch <- DateTime.to_unix(datetime, :millisecond) do
      for sensor <- observer.sensors do
        get_sensor_value(header, values, sensor, observer.device_id, epoch)
        |> send()
      end
    else
      err -> IO.inspect({:wolkietolkie, err})
    end
  end

  defp request_wolkie_tolkie(device_id, api_key) do
    with {:ok, request} <- HTTPoison.get("https://extern.wolkytolky.com/v1.3/stationdata/?stationId=#{device_id}&type=csv&apiKey=#{api_key}") do
      {:ok, request.body}
    else
      error ->
        IO.inspect {"Wolkie Tolkie", error}
        error
    end
  end

  defp get_sensor_value(header, info, sensor, device_id, epoch) do
    case sensor_value(header, info, sensor.field_name) do
      nil -> nil
      value -> {epoch, value, device_id, sensor}
    end
  end

  defp sensor_value(header, info, field_name) do
    case index(header, field_name) do
      nil -> nil
      i -> Enum.at(info, i)
    end
  end

  defp index(header, field_name) do
    case Enum.with_index(header) |> Enum.find(fn {element, _index} -> element == field_name end) do
      {_element, index} -> index - 1
      _ -> nil
    end
  end

  defp send({epoch, value, device_id, sensor }) do
    Events.create_event_and_broadcast(value, device_id, sensor, epoch)
  end
end
