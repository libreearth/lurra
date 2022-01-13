defmodule LurraWeb.DownloadDataController do
  use LurraWeb, :controller

  alias Lurra.Events

  def index(conn, %{"device_id" => device_id, "sensor_type" => sensor_type,"from" => from_time, "to" => to_time, "timezone" => timezone}) do

    ch_conn =
      conn
      |> put_resp_content_type("application/force-download")
      |> put_resp_header("content-disposition", ~s[attachment; filename="points.csv"])
      |> send_chunked(:ok)

    Lurra.Repo.transaction(fn ->


      create_csv_stream(device_id, sensor_type, from_time, to_time, timezone)
      |> Enum.reduce_while(ch_conn, fn chunk, conn ->
        case Plug.Conn.chunk(conn, chunk) do
          {:ok, conn} ->
            {:cont, conn}

          {:error, :closed} ->
            {:halt, conn}
        end
      end)
    end)

    ch_conn
  end

  defp create_csv_stream(device_id, sensor_type, from_time, to_time, timezone) do
    {_days, {hours, minutes, _secs}} =
      :calendar.time_difference(:calendar.universal_time(), Timex.now(timezone) |> DateTime.to_naive() |> NaiveDateTime.to_erl())

    header =
      Stream.unfold(
        "time (UTC+#{hours |> zero_pad}:#{minutes |> zero_pad});Value\n",
        &String.next_codepoint/1
      )



    body =
      Events.stream_events(device_id, sensor_type, from_time, to_time)
      |> Stream.map(fn m ->
        [
          format_date(m.timestamp, timezone),
          String.to_float(m.payload)
        ]
      end)
      |> CSV.encode(separator: ?;, delimiter: "\n")

    Stream.concat(header, body)
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
end
