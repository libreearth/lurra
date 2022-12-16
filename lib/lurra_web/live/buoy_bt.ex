defmodule LurraWeb.BuoyBt do
  use Surface.LiveView

  alias Lurra.Monitoring
  alias Lurra.Events

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:connected, false)}
  end

  def handle_event("connected", %{"date" => date, "uid" => uid, "sensors" => sensors }, socket) do
    {
      :noreply,
      socket
      |> assign(:connected, true)
      |> assign(:buoy_date, date)
      |> assign(:buoy_uid, uid)
      |> assign(:buoy_sensors, sensors)
    }
  end

  def handle_event("disconnected", _data, socket) do
    {
      :noreply,
      socket
      |> assign(:connected, false)
      |> assign(:buoy_date, nil)
      |> assign(:buoy_uid, nil)
      |> assign(:buoy_sensors, nil)
    }
  end

  def handle_event("save_data", data, socket) do
    uid = socket.assigns.buoy_uid
    case Monitoring.get_observer_by_device_id(uid) do
      nil ->
        {:noreply, push_event(socket, "show_message", %{message: "Buoy not found, please register the buoy."})}
      observer ->
        create_event(data, observer)
        {:noreply, push_event(socket, "show_message", %{message: "Buoy data saved correctly."})}
    end
  end

  defp create_event([datum], observer) do
    epoch = datum["epoch"]
    for {sensor_type, payload} <- Map.drop(datum, ["epoch"]) do
      case  Monitoring.get_sensor_by_type(sensor_type) do
        nil -> nil
        sensor -> Events.create_event_and_broadcast(payload, observer.device_id, sensor, epoch)
      end
    end
  end

  defp create_event([datum | data], observer) do
    epoch = datum["epoch"]
    for {sensor_type, payload} <- Map.drop(datum, ["epoch"]) do
      Events.create_event(payload, observer.device_id, sensor_type, epoch)
    end
    create_event(data, observer)
  end

  defp print_sensors(sensors) do
    sensors
    |> Enum.map(fn (sensor) -> {sensor, Monitoring.get_sensor_by_type(sensor)} end)
    |> Enum.map(fn {sensor_type, sensor} -> if is_nil(sensor) do sensor_type else sensor.name end end)
    |> Enum.join(", ")
  end
end
