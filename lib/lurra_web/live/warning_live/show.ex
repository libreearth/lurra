defmodule LurraWeb.WarningLive.Show do
  use LurraWeb, :live_view

  alias Lurra.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:warning, Events.get_warning!(id))}
  end

  defp page_title(:show), do: "Show Warning"
  defp page_title(:edit), do: "Edit Warning"
end
