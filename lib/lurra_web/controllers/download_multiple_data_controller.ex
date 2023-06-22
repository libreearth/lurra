defmodule LurraWeb.DownloadMultipleDataController do
  use LurraWeb, :controller
  import Lurra.TimezoneHelper

  alias Lurra.Events
  alias Lurra.Monitoring

  def index(conn, %{"sensors" => sensors,"from" => from_time, "to" => to_time, "interval" => interval, "timezone" => timezone, "lablog" => download_lablog}) do

    ch_conn =
      conn
      |> put_resp_content_type("application/force-download")
      |> put_resp_header("content-disposition", ~s[attachment; filename="points.csv"])
      |> send_chunked(:ok)

      create_csv_stream(sensors, from_time, to_time, interval, timezone, download_lablog)
      |> Stream.chunk_every(10_000)
      |> Enum.reduce_while(ch_conn, fn chunk, conn ->
        case Plug.Conn.chunk(conn, chunk) do
          {:ok, conn} ->
            {:cont, conn}

          {:error, reason} ->
            IO.puts "Error: #{inspect reason}"
            {:halt, conn}
        end
      end)


    ch_conn
  end

  def create_csv_stream(sensors, from_time, to_time, interval, timezone, "true") do
    sensors =
      sensors
      |> String.split(",")
      |> Enum.map(& String.split(&1, "-") |> List.to_tuple())
      |> Enum.map(&find_observer_sensor_tuple/1)

    events = sensors
      |> to_device_id_type_tuple()
      |> Enum.map(& query_events(&1, from_time, to_time))

    time_values = Enum.to_list(String.to_integer(from_time)..String.to_integer(to_time)//String.to_integer(interval)*1000)

    header = create_header(timezone, sensors, "true")

    lablogs = Events.query_lablogs(from_time, to_time)

    body =
      time_values
      |> Stream.transform({events, 0}, fn t, {events, old_t} ->
        lablog_str =
          lablogs
          |> Enum.filter(fn lablog -> lablog.timestamp >= old_t and lablog.timestamp < t end)
          |> Enum.map(fn lablog -> "#{lablog.payload} - #{lablog.user}" end)
          |> Enum.join(", ")

        {values, new_events_list} = find_interpolated_values(t, events)
        {[[format_date(t, timezone) | values] ++ [lablog_str]], {new_events_list, t}}
      end)
      |> CSV.encode(separator: ?;, delimiter: "\n")

    Stream.concat(header, body)
  end

  def create_csv_stream(sensors, from_time, to_time, interval, timezone, download_lablog) do
    sensors =
      sensors
      |> String.split(",")
      |> Enum.map(& String.split(&1, "-") |> List.to_tuple())
      |> Enum.map(&find_observer_sensor_tuple/1)

    events = sensors
      |> to_device_id_type_tuple()
      |> Enum.map(& query_events(&1, from_time, to_time))

    time_values = Enum.to_list(String.to_integer(from_time)..String.to_integer(to_time)//String.to_integer(interval)*1000)

    header = create_header(timezone, sensors, download_lablog)

    body =
      time_values
      |> Stream.transform(events, fn m, events ->
        {values, new_events_list} = find_interpolated_values(m, events)
        {[[format_date(m, timezone) | values]], new_events_list}
      end)
      |> CSV.encode(separator: ?;, delimiter: "\n")

    Stream.concat(header, body)
  end

  defp create_header(timezone, sensors, "true") do

    Stream.unfold(
      "time (#{time_difference_from_utc(timezone)});#{header_from_sensor_tuple(sensors)};Lablog\n",
      &String.next_codepoint/1
    )
  end

  defp create_header(timezone, sensors, _download_lablog) do
    Stream.unfold(
      "time (#{time_difference_from_utc(timezone)});#{header_from_sensor_tuple(sensors)}\n",
      &String.next_codepoint/1
    )
  end

  defp find_interpolated_values(time, events_list) do
    interpolated_list = Enum.map(events_list, & find_interpolated_value(time, &1))
    {
      Enum.map(interpolated_list, & elem(&1, 0)),
      Enum.map(interpolated_list, & elem(&1, 1))
    }
  end

  defp find_interpolated_value(time, events) do
    {a, b, new_events} = find_intervalues(time, events)
    if not is_nil(a) and not is_nil(b) do
        av = payload_to_value(a)
        bv = payload_to_value(b)
        pc = (time - a.timestamp)/(b.timestamp - a.timestamp)
        {av + (bv - av)*pc, new_events}
    else
      {nil, events}
    end
  end

  defp find_intervalues(time, [e1 | [e2 | _rest]] = list) when e1.timestamp <= time and e2.timestamp > time do
    {e1, e2, list}
  end

  defp find_intervalues(time, [e1 | [e2 | _rest]] = list) when e1.timestamp > time and e2.timestamp > time do
    {nil, nil, list}
  end

  defp find_intervalues(time, [_e1 | rest]) do
    find_intervalues(time, rest)
  end

  defp find_intervalues(_time, _list) do
    {nil, nil, nil}
  end

  defp payload_to_value(nil), do: nil
  defp payload_to_value(event), do: Float.parse(event.payload) |> elem(0)

  defp find_observer_sensor_tuple({observer_id, sensor_type}) do
    {
      Monitoring.get_observer_no_preload!(observer_id),
      Monitoring.get_sensor_by_type(sensor_type)
    }
  end

  defp header_from_sensor_tuple(sensors) do
    sensors
    |> Enum.map(fn {observer, sensor} -> "#{observer.name} #{sensor.name} (#{sensor.unit})" end)
    |> Enum.join(";")
  end

  defp query_events({device_id, type}, from_time, to_time), do: Events.list_events(device_id, Integer.to_string(type), String.to_integer(from_time), String.to_integer(to_time))

  defp to_device_id_type_tuple(observer_sensor_tuples), do: Enum.map(observer_sensor_tuples, fn {observer, sensor} -> {observer.device_id, sensor.sensor_type} end)
end
