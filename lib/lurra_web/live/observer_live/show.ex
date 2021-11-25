defmodule LurraWeb.ObserverLive.Show do
  use LurraWeb, :live_view

  alias Lurra.Monitoring

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:observer, Monitoring.get_observer!(id))}
  end

  defp page_title(:show), do: "Show Observer"
  defp page_title(:edit), do: "Edit Observer"
end
