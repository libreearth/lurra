defmodule LurraWeb.DownloadMultipleDataController do
  use LurraWeb, :controller

  alias Lurra.Events
  alias Lurra.Monitoring

  def index(conn, %{"sensors" => sensors,"from" => from_time, "to" => to_time, "interval" => interval, "timezone" => timezone}) do

    ch_conn =
      conn
      |> put_resp_content_type("application/force-download")
      |> put_resp_header("content-disposition", ~s[attachment; filename="points.csv"])
      |> send_chunked(:ok)


      create_csv_stream(sensors, from_time, to_time, interval, timezone)
      |> Enum.reduce_while(ch_conn, fn chunk, conn ->
        case Plug.Conn.chunk(conn, chunk) do
          {:ok, conn} ->
            {:cont, conn}

          {:error, :closed} ->
            {:halt, conn}
        end
      end)


    ch_conn
  end

  defp create_csv_stream(sensors, from_time, to_time, interval, timezone) do
    {_days, {hours, minutes, _secs}} =
      :calendar.time_difference(:calendar.universal_time(), Timex.now(timezone) |> DateTime.to_naive() |> NaiveDateTime.to_erl())

    sensors =
      sensors
      |> String.split(",")
      |> Enum.map(& String.split(&1, "-") |> List.to_tuple())
      |> Enum.map(&find_observer_sensor_tuple/1)

    events = sensors
      |> to_device_id_type_tuple()
      |> Enum.map(& query_events(&1, from_time, to_time))

    time_values = Enum.to_list(String.to_integer(from_time)..String.to_integer(to_time)//String.to_integer(interval)*1000)

    header =
      Stream.unfold(
        "time (UTC+#{hours |> zero_pad}:#{minutes |> zero_pad});#{header_from_sensor_tuple(sensors)}\n",
        &String.next_codepoint/1
      )


    body =
      time_values
      |> Stream.transform(events, fn m, events ->
        {values, new_events_list} = find_interpolated_values(m, events)
        {[[format_date(m, timezone) | values]], new_events_list}
      end)
      |> CSV.encode(separator: ?;, delimiter: "\n")

    Stream.concat(header, body)
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

  defp find_observer_sensor_tuple({observer_id, sensor_id}) do
    {
      Monitoring.get_observer_no_preload!(observer_id),
      Monitoring.get_sensor!(sensor_id)
    }
  end

  defp header_from_sensor_tuple(sensors) do
    sensors
    |> Enum.map(fn {observer, sensor} -> "#{observer.name} #{sensor.name} (#{sensor.unit})" end)
    |> Enum.join(";")
  end

  defp format_date(unix_time, timezone) do
    date = Timex.from_unix(unix_time, :millisecond) |> Timex.to_datetime(timezone)

    "#{date.day}/#{date.month |> zero_pad}/#{date.year} #{date.hour |> zero_pad}:#{date.minute |> zero_pad}:#{date.second |> zero_pad}"
  end

  defp zero_pad(number, amount \\ 2) do
    number
    |> Integer.to_string()
    |> String.pad_leading(amount, "0")
  end

  defp query_events({device_id, type}, from_time, to_time), do: Events.list_events(device_id, Integer.to_string(type), String.to_integer(from_time), String.to_integer(to_time))

  defp to_device_id_type_tuple(observer_sensor_tuples), do: Enum.map(observer_sensor_tuples, fn {observer, sensor} -> {observer.device_id, sensor.sensor_type} end)
end
