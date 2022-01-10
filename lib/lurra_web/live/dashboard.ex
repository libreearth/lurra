defmodule LurraWeb.Dashboard do
  use Surface.LiveView

  alias LurraWeb.Components.EcoObserver
  alias LurraWeb.Endpoint

  @events_topic "events"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@events_topic)
    end
    observers = Lurra.Monitoring.list_observers()
    socket = socket
    |> assign(:observers, observers)
    |> assign(:readings, initial_readings())

    {:ok, socket}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, device_id: device_id, type: type}, topic: "events"}, socket) do
    {
      :noreply,
      socket
      |> assign(:readings, Map.put(socket.assigns.readings, {device_id, type}, payload))
    }
  end

  def filter_device_readings(readings, device_id) do
    readings
    |> Enum.filter(fn {{dev_id, _type}, _payload} -> dev_id == device_id end)
    |> Enum.map(fn {{_device, type}, payload} -> {type, payload} end)
    |> Enum.into(%{})
  end

  defp payload(nil), do: nil
  defp payload(event), do: event.payload

  defp parse_float(nil) do
    nil
  end

  defp parse_float(text) do
    {n, _} = Float.parse(text)
    n
  end

  defp parse_int(nil) do
    nil
  end

  defp parse_int(text) do
    {n, _} = Integer.parse(text)
    n
  end

  def initial_readings() do
    Lurra.Events.get_last_events()
    |> Enum.map(fn reading -> {{reading.device_id, parse_int(reading.type)}, reading |> payload() |> parse_float()} end)
    |> Enum.into(%{})
    |> IO.inspect
  end
end
