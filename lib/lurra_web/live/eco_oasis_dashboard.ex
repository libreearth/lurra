defmodule LurraWeb.EcoOasisDashboard do
  use Surface.LiveView

  alias Lurra.Core.EcoOasis.Server.ServerSupervisor
  alias Surface.Components.Form.Select
  alias Surface.Components.Link
  alias Surface.Components.Form
  alias LurraWeb.Components.Element
  alias LurraWeb.Endpoint
  alias LurraWeb.Router.Helpers, as: Routes

  @default_timezone "UTC"
  @events_topic "eco_oasis"
  @storage_key "LURRA_SELECTED_ECO"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@events_topic)
    end
    selected_eco_oasis_id = get_connect_params(socket)["restore"]
    socket = socket
    |> assign(:show, connected?(socket))
    |> assign(:eco_oases, ServerSupervisor.list_all() |> Enum.map(fn eco -> {eco.name, eco.id} end))
    |> assign(:selected_eco, get_selected_eco_oasis(selected_eco_oasis_id) )
    |> assign_timezone()

    {:ok, socket}
  end

  def handle_info(%{event: "eco_oasis_updated", payload: %{id: updated_id}, topic: @events_topic}, socket) do
    current_id = socket.assigns.selected_eco.id
    {
      :noreply,
      socket
      |> maybe_assign_updated_eco_oasis(current_id, updated_id)
    }
  end

  def handle_info({:save_eco_oasis_browser, id}, socket) do
    {:noreply, push_event(socket, "store", %{"key" => @storage_key, "data" => id})}
  end

  def handle_event("change", %{"eco_oasis" => [id]}, socket) do
    send(self(), {:save_eco_oasis_browser,id})
    {
      :noreply, socket
      |> assign(:selected_eco, ServerSupervisor.get_eco_oasis(id))
    }
  end

  defp maybe_assign_updated_eco_oasis(socket, current_id, updated_id) when current_id != updated_id, do: socket
  defp maybe_assign_updated_eco_oasis(socket, current_id, updated_id) when current_id == updated_id, do: assign(socket, :selected_eco, ServerSupervisor.get_eco_oasis(current_id))

  defp assign_timezone(socket) do
    timezone = get_connect_params(socket)["timezone"] || @default_timezone
    assign(socket, timezone: timezone)
  end

  defp get_selected_eco_oasis(nil), do: ServerSupervisor.list_all() |> List.first()
  defp get_selected_eco_oasis(id), do: ServerSupervisor.get_eco_oasis(id)
end
