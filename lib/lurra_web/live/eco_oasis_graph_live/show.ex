defmodule LurraWeb.EcoOasisGraphLive.Show do
  use Surface.LiveView

  alias Lurra.Core.EcoOasis.Server.ServerSupervisor
  alias LurraWeb.Components.Dome.Tank
  alias LurraWeb.Components.Dome.Cloud
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

  def render(assigns) do
    ~F"""
      <div class="eco-oasis-gr">
        {#for element <- @eco_oasis.elements}
          {#if element.type == "Tank"}
            <Tank x={0} y={0} width={50} height={200}
              max_level={1600} min_level={1000} label={element.name} level={get_measurement(element, "Water level")}
              temperature={get_measurement(element, "Water temperature")} air_temperature={get_measurement(element, "Air temperature")}
              humidity={get_measurement(element, "Air humidity")} min_temperature={10} max_temperature={30}
              />
          {#elseif element.type == "Slice"}
            <Tank x={0} y={0} width={50} height={100}
            max_level={400} min_level={0} label={element.name} level={get_measurement(element, "Water level")}
            temperature={get_measurement(element, "Water temperature")} air_temperature={get_measurement(element, "Air temperature")}
            humidity={get_measurement(element, "Air humidity")} min_temperature={10} max_temperature={30}
            />
          {/if}
        {/for}
      </div>
    """
  end

  defp get_measurement(element, location_type) do
    Enum.find(element.measurements, fn {{_uid, _sensor_type}, {_name, _value, _units, _format, location}} -> location == location_type end)
    |> value()
  end

  defp value(nil), do: nil
  defp value({{_uid, _sensor_type}, {_name, value, _units, _format, _location}}), do: value

  defp maybe_assign_updated_eco_oasis(socket, current_id, updated_id) when current_id != updated_id, do: socket
  defp maybe_assign_updated_eco_oasis(socket, current_id, updated_id) when current_id == updated_id, do: assign(socket, :eco_oasis, ServerSupervisor.get_eco_oasis(current_id))

end
