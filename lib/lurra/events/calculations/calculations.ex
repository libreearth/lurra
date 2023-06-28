defmodule Lurra.Events.Calculations do
  @moduledoc """
  This module contains all the calculations that are used to make calculations over the
  events.
  """
  import Ecto.Query

  @doc """
  This functions calcultes the number of swings that a sensor has registered. Needs begin and end dates, the device and the sensor.
  """
  def calculate_number_of_swings(begin_date, end_date, threshold, device_id, sensor_id) do
    query = from e in Lurra.Events.Event,
      where: e.device_id == ^device_id and  e.type == ^sensor_id and e.timestamp >= ^begin_date and e.timestamp <= ^end_date,
      select: e.payload

    Lurra.Repo.transaction(fn ->
      query
      |> Lurra.Repo.stream()
      |> Stream.map(&parse_float/1)
      |> soften()
      |> count_up_peaks(threshold)
      |> Enum.count()
    end)
  end

  defp soften(stream) do
    Stream.transform(stream, [], fn (payload, acc) ->
      ls = [payload | acc]
      softened = [Enum.sum(ls) / length(ls)]
      {softened, Enum.take(ls, 5)}
    end)
  end

  defp count_up_peaks(stream, threshold) do
    Stream.transform(stream, nil, fn (payload, last) ->
      crossed_threshold?(last, payload, threshold)
    end)
  end

  defp crossed_threshold?(nil, payload, threshold) do
    if payload > threshold do
      {[:ok], payload}
    else
      {[], payload}
    end
  end

  defp crossed_threshold?(last, payload, threshold) do
    if last <= threshold and payload > threshold do
      {[:ok], payload}
    else
      {[], payload}
    end
  end

  defp parse_float(payload) do
    case Float.parse(payload) do
      {float, _} -> float
      :error -> 0.0
    end
  end

end
