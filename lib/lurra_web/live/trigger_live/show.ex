defmodule LurraWeb.TriggerLive.Show do
  use LurraWeb, :live_view

  alias Lurra.Triggers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:trigger, Triggers.get_trigger!(id))}
  end

  defp page_title(:show), do: "Show Trigger"
  defp page_title(:edit), do: "Edit Trigger"
end
