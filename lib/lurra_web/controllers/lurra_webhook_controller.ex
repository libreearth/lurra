defmodule LurraWeb.LurraWebhookController do
  use LurraWeb, :controller

  alias Lurra.Monitoring
  alias Lurra.Events

  plug LurraWeb.PushTokenPlug

  def webhook(conn, %{ "uplink_message" => %{"frm_payload" => payload }, "end_device_ids" => %{ "device_id" => device_id }} ) do
    payload
    |> Base.decode64!()
    |> read_payload(device_id)
    json(conn, nil)
  end

  def webhook(conn, %{ "join_accept" => %{}, "end_device_ids" => %{ "device_id" => device_id }} ) do
    IO.puts("#{device_id} joined!!")
    json(conn, nil)
  end

  def webhook(conn, %{ "end_device_ids" => %{ "device_id" => device_id }} = ms) do
    IO.puts("#{device_id} unrecognize message!!")
    IO.inspect ms
    json(conn, nil)
  end

  def read_payload(<<>>, _device_id), do: nil

  def read_payload(<<0xFF, 0x01>>, device_id) do
    IO.puts("Hello mesage v1 recieved from #{device_id}!!")
    case Lurra.Monitoring.get_observer_by_device_id(device_id) do
      %Lurra.Monitoring.Observer{max_depth_level: max_level, min_depth_level: min_level, fan_level: fan_level} ->
        payload = write_binary(min_level, "float") <> write_binary(max_level, "float") <> write_binary(fan_level, "float")
        Lurra.TheThingsNetwork.send_message(device_id, 15, payload)
      _ -> :error
    end
    nil
  end

  def read_payload(<<type, value_bin::binary-size(4), rest::binary>>, device_id) do
    case Monitoring.get_sensor_by_type(type) do
      nil -> nil
      sensor ->
        value = read_binary_value(value_bin, sensor.value_type)
        Events.create_event_and_broadcast(value, device_id, sensor)
        read_payload(rest, device_id)
    end
  end

  def read_binary_value(value_bin, "string") do
    value_bin
  end

  def read_binary_value(value_bin, "int16") do
    <<0, 0, value::integer-signed-size(16)>> = value_bin
    value
  end

  def read_binary_value(value_bin, "int32") do
    <<value::integer-signed-size(32)>> = value_bin
    value
  end

  def read_binary_value(value_bin, "float") do
    <<value::float-size(32)>> = value_bin
    value
  end

  defp write_binary(nil, "float"), do: <<0xFF, 0xFF, 0xFF, 0xFF>>
  defp write_binary(value, "float") do
    <<value::float-size(32)>>
  end
end
