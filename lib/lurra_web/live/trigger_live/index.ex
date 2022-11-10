defmodule LurraWeb.TriggerLive.Index do
  use LurraWeb, :live_view

  alias Lurra.Triggers
  alias Lurra.Triggers.Trigger
  alias Lurra.Monitoring

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :triggers, list_triggers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Trigger")
    |> assign(:trigger, Triggers.get_trigger!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Trigger")
    |> assign(:trigger, %Trigger{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Triggers")
    |> assign(:trigger, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    trigger = Triggers.get_trigger!(id)
    {:ok, _} = Triggers.delete_trigger(trigger)

    Lurra.Triggers.Server.update()
    {:noreply, assign(socket, :triggers, list_triggers())}
  end

  defp list_triggers do
    Triggers.list_triggers()
  end

  defp get_device_name(device_id) do
    case Monitoring.get_observer_by_device_id(device_id) do
      nil -> "Observer deleted"
      device -> device.name
    end
  end

  defp get_sensor_name(sensor_type) do
    case Monitoring.get_sensor_by_type(sensor_type) do
      nil -> "Sensor deleted"
      sensor -> sensor.name
    end
  end
end
