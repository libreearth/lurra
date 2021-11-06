defmodule LurraWeb.LurraWebhookController do
  use LurraWeb, :controller

  def webhook(conn, %{ "uplink_message" => %{"frm_payload" => payload }} = params) do
    payload
    |> Base.decode64!()
    |> read_payload()

    json(conn, nil)
  end

  def create_event(value, sensor) do
    valid_attrs = %{h3id: "", payload: "#{value}", timestamp: DateTime.utc_now(), type: "#{sensor.sensor_type}"}

    case Lurra.Events.create_event(valid_attrs) do
      {:ok, event} ->
       nil
      error ->
       IO.inspect error
       nil
     end
  end

  def read_payload(<<>>), do: nil

  def read_payload(<<type, value_bin::binary-size(4), rest::binary>>) do
    case Lurra.Monitoring.get_sensor_by_type(type) do
      nil -> nil
      sensor ->
        value = read_binary_value(value_bin, sensor.value_type)
        create_event(value, sensor)
        read_payload(rest)
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
