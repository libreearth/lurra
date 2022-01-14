defmodule LurraWeb.LurraWebhookController do
  use LurraWeb, :controller

  alias Lurra.Monitoring
  alias Lurra.Events

  def webhook(conn, %{ "uplink_message" => %{"frm_payload" => payload }, "end_device_ids" => %{ "device_id" => device_id }} ) do
    payload
    |> Base.decode64!()
    |> read_payload(device_id)
    json(conn, nil)
  end

  def read_payload(<<>>, _device_id), do: nil

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
end
