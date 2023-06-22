defmodule Lurra.TimezoneHelper do
  @moduledoc """
  Helper functions for dealing with timezones
  """

  @default_timezone "UTC"

  def assign_timezone(socket) do
    timezone = Phoenix.LiveView.get_connect_params(socket)["timezone"] || @default_timezone
    Phoenix.LiveView.assign(socket, timezone: timezone)
  end

  def format_date(unix_time, timezone) do
    date = unix_time_to_local(unix_time, timezone)

    "#{date.day}/#{date.month |> zero_pad}/#{date.year} #{date.hour |> zero_pad}:#{date.minute |> zero_pad}:#{date.second |> zero_pad}"
  end

  def unix_time_to_local(unix_time, timezone) do
    Timex.from_unix(unix_time, :millisecond) |> Timex.to_datetime(timezone)
  end

  def local_text_to_unix(text_date, timezone) do
    Timex.parse!(text_date, "{YYYY}-{M}-{D}T{h24}:{m}") |> Timex.to_datetime(timezone) |> DateTime.to_unix(:millisecond)
  end

  def time_difference_from_utc(timezone) do
    {_days, {hours, minutes, _secs}} =
      :calendar.time_difference(:calendar.universal_time(), Timex.now(timezone) |> DateTime.to_naive() |> NaiveDateTime.to_erl())

      "UTC+#{hours |> zero_pad}:#{minutes |> zero_pad}"
  end

  defp zero_pad(number, amount \\ 2) do
    number
    |> Integer.to_string()
    |> String.pad_leading(amount, "0")
  end

end
