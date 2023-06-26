defmodule LurraWeb.WarningLive.Index do
  use LurraWeb, :live_view

  alias Lurra.Events
  alias Lurra.Events.Warning
  alias Lurra.Monitoring
  alias Lurra.Accounts

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    {:ok, assign(socket, :warnings, list_warnings()) |> assign(:user, user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Warning")
    |> assign(:warning, Events.get_warning!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Warning")
    |> assign(:warning, %Warning{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Warnings")
    |> assign(:warning, nil)
  end

  def handle_event("mark-all-as-read", _params, socket) do
    Lurra.Accounts.mark_all_warnings_as_read(socket.assigns.user)
    {:noreply, push_event(socket, "reload", %{})}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    warning = Events.get_warning!(id)
    {:ok, _} = Events.delete_warning(warning)

    {:noreply, assign(socket, :warnings, list_warnings())}
  end

  defp list_warnings do
    Events.list_warnings_limit(100)
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
