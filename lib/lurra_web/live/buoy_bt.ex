defmodule LurraWeb.BuoyBt do
  use Surface.LiveView

  alias Lurra.Monitoring
  alias Lurra.Events
  alias Lurra.Core.BuoyData

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:connected, false)
      |> assign(:extracted_data, 0)
    }
  end

  def handle_event("connected", %{"date" => date, "uid" => uid, "sensors" => sensors, "battery" => battery, "size" => size }, socket) do
    BuoyData.register(uid)
    data_size = extracted_data_size(uid)
    {
      :reply,
      %{extracted_data_size: data_size},
      socket
      |> assign(:connected, true)
      |> assign(:buoy_date, date)
      |> assign(:buoy_uid, uid)
      |> assign(:battery, battery)
      |> assign(:size, size)
      |> assign(:buoy_sensors, sensors)
      |> assign(:extracted_data, data_size)
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
      |> assign(:battery, nil)
      |> assign(:size, nil)
      |> assign(:extracted_data, nil)
    }
  end

  def handle_event("extract_data", data, socket) do
    case socket.assigns.buoy_uid do
      nil -> :undefined
      uid -> insert(uid, data)
    end
    {:noreply, socket}
  end

  def handle_event("clear_extracted_data", _data, socket) do
    case socket.assigns.buoy_uid do
      nil ->
        {:noreply, socket}
      uid ->
        delete_all_objects(uid)
        {:noreply, assign(socket, :extracted_data, extracted_data_size(uid))}
    end
  end

  def handle_event("recalculate_extracted_data", _data, socket) do
    data_size = extracted_data_size(socket.assigns.buoy_uid)
    {:reply, %{extracted_data_size: data_size}, assign(socket, :extracted_data, data_size)}
  end

  def handle_event("download_data", _data, socket) do
    table = String.to_atom(socket.assigns.buoy_uid)
    csv = :ets.tab2list(table)
    |> Enum.map(fn {_epoch, data} -> data end)
    |> Enum.map(fn data -> to_csv_line(socket.assigns.buoy_sensors, data) end)
    |> Enum.join("\n")
    {:reply, %{csv: csv}, socket}
  end

  def handle_event("upload_data", _data, socket) do
    table = String.to_atom(socket.assigns.buoy_uid)
    uid = socket.assigns.buoy_uid
    case Monitoring.get_observer_by_device_id(uid) do
      nil ->
        {:noreply, push_event(socket, "show_message", %{message: "Buoy not found, please register the buoy."})}
      observer ->
        :ets.tab2list(table)
        |> Enum.map(fn {_epoch, data} -> data end)
        |> create_event(observer)
        {:noreply, push_event(socket, "show_message", %{message: "Buoy data saved correctly."})}
    end
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
    for {sensor_type, payload} <- Map.drop(datum, ["epoch", "read", "timestamp"]) do
      case  Monitoring.get_sensor_by_type(sensor_type) do
        nil -> nil
        sensor -> Events.create_event_and_broadcast(payload, observer.device_id, sensor, epoch)
      end
    end
  end

  defp create_event([datum | data], observer) do
    epoch = datum["epoch"]
    for {sensor_type, payload} <- Map.drop(datum, ["epoch", "read", "timestamp"]) do
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

  defp to_csv_line(sensors, %{"timestamp" => timestamp} = data) do
    [timestamp | for sensor <- sensors do
      data[sensor]
    end]
    |> Enum.join(";")
  end

  defp insert(uid, %{"epoch" => epoch} = data) do
    case epoch do
      nil -> nil
      epoch ->
        String.to_atom(uid)
        |> :ets.insert({epoch, data})
    end

  end

  defp delete_all_objects(uid) do
    String.to_atom(uid)
    |> :ets.delete_all_objects()
  end

  defp extracted_data_size(uid) do
    table = String.to_atom(uid)
    last_key = :ets.last(table)
    case last_key do
      key when is_number(key) ->
        %{"read" => read} = :ets.lookup_element(table, key, 2)
        read
      :"$end_of_table" -> 0
    end
  end
end
