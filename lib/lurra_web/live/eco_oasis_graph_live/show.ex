defmodule LurraWeb.EcoOasisGraphLive.Show do
  use Surface.LiveView

  alias Lurra.Core.EcoOasis.Server.ServerSupervisor
  alias LurraWeb.Components.Dome.Element
  alias LurraWeb.Endpoint

  @events_topic "eco_oasis"

  def mount(%{"id" => eco_oasis_id}, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@events_topic)
    end
    eco_oasis = ServerSupervisor.get_eco_oasis(eco_oasis_id)
    {
      :ok,
      socket
      |> assign(:eco_oasis, eco_oasis)
    }
  end

  def handle_info(%{event: "eco_oasis_updated", payload: %{id: updated_id}, topic: @events_topic}, socket) do
    current_id = socket.assigns.eco_oasis.id
    {
      :noreply,
      socket
      |> maybe_assign_updated_eco_oasis(current_id, updated_id)
    }
  end

  def handle_event("dropped-over", %{"origin" => origin, "destiny" => destiny}, socket) do
    eco_oasis = socket.assigns.eco_oasis
    element1 = find_element_by_cell(eco_oasis, origin)
    element2 = find_element_by_cell(eco_oasis, destiny)
    change_element_location(eco_oasis.id, element1, destiny)
    change_element_location(eco_oasis.id, element2, origin)
    {:noreply, socket |> assign(:eco_oasis, ServerSupervisor.get_eco_oasis(eco_oasis.id))}
  end

  def render(assigns) do
    ~F"""
      <div class="eco-oasis-gr">
        {#for row <- ["A", "B", "C"]}
          <div class="eco-oasis-row">
            {#for col <- [0,1,2,3,4,5,6,7,8,9,10,11,12]}
              <div id={"#{row}#{col}"} phx-value-id={find_element_id(@eco_oasis, row, col)} class="tank dropable" draggable="true" :hook="DropableDome">
                <Element element = {find_element(@eco_oasis, row, col)} />
              </div>
            {/for}
          </div>
        {/for}
      </div>
    """
  end

  defp change_element_location(_eco_oasis_id, nil, _location), do: nil
  defp change_element_location(eco_oasis_id, %{id: element_id}, location) do
    ServerSupervisor.put_element_data(eco_oasis_id, element_id, "location", location)
  end

  defp find_element(eco_oasis, row, col) do
    location = "#{row}#{col}"
    Enum.find(eco_oasis.elements, fn element -> element_location(element) == location end)
  end

  defp find_element_by_cell(eco_oasis, id) do
    Enum.find(eco_oasis.elements, fn element -> element_location(element) == id end)
  end

  defp element_location(%{data: %{"location" => location}}), do: location
  defp element_location(_element), do: nil

  defp find_element_id(eco_oasis, row, col) do
    case find_element(eco_oasis, row, col) do
      nil -> ""
      element -> element.id
    end
  end

  defp maybe_assign_updated_eco_oasis(socket, current_id, updated_id) when current_id != updated_id, do: socket
  defp maybe_assign_updated_eco_oasis(socket, current_id, updated_id) when current_id == updated_id, do: assign(socket, :eco_oasis, ServerSupervisor.get_eco_oasis(current_id))

end
