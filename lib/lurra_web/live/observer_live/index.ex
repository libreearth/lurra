defmodule LurraWeb.ObserverLive.Index do
  use LurraWeb, :live_view

  alias Lurra.Monitoring
  alias Lurra.Monitoring.Observer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :observers, list_observers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Observer")
    |> assign(:observer, Monitoring.get_observer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Observer")
    |> assign(:observer, %Observer{sensors: []})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Observers")
    |> assign(:observer, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    observer = Monitoring.get_observer!(id)
    {:ok, _} = Monitoring.delete_observer(observer)

    {:noreply, assign(socket, :observers, list_observers())}
  end

  def handle_event("archive", %{"id" => id}, socket) do
    observer = Monitoring.get_observer!(id)
    {:ok, _} =Monitoring.update_observer(observer, %{archived: true})

    {:noreply, assign(socket, :observers, list_observers())}
  end

  def handle_event("unarchive", %{"id" => id}, socket) do
    observer = Monitoring.get_observer!(id)
    {:ok, _} =Monitoring.update_observer(observer, %{archived: false})

    {:noreply, assign(socket, :observers, list_observers())}
  end


  def handle_event("reboot", %{"id" => device_id}, socket) do
    Lurra.TheThingsNetwork.send_message(device_id, 14, <<0x00>>)
    {:noreply, socket}
  end

  defp list_observers do
    Monitoring.list_observers_ordered()
  end
end
