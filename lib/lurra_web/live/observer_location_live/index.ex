defmodule LurraWeb.ObserverLocationLive.Index do
  use Surface.LiveView

  alias LurraWeb.Components.EcoObserverLocation
  alias LurraWeb.Endpoint
  alias Lurra.Monitoring
  alias LurraWeb.Components.Dialog
  alias LurraWeb.ObserverLocationLive.FormComponent
  alias LurraWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    observers = Lurra.Monitoring.list_observers()
    socket = socket
    |> assign(:observers, observers)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:observer, Monitoring.get_observer!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: Routes.observer_location_index_path(Endpoint, :index))}
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
end
