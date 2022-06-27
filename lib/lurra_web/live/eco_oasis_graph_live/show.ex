defmodule LurraWeb.EcoOasisGraphLive.Show do
  use Surface.LiveView

  alias LurraWeb.Components.Dome.Tank
  alias LurraWeb.Components.Dome.Cloud
  alias LurraWeb.Endpoint

  @events_topic "events"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@events_topic)
    end

    {
      :ok,
      socket
      |> assign(:readings, Lurra.Events.ReadingsCache.get_readings())
    }
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, device_id: device_id, type: type}, topic: "events"}, socket) do
    {
      :noreply,
      socket
      |> assign(:readings, Map.put(socket.assigns.readings, {device_id, type}, payload))
    }
  end

  def render(assigns) do
    ~F"""
      <svg class="eco-oasis-gr">
        <Tank x={400} y={100} width={50} height={200}
          max_level={1500} min_level={1300} label="Dinoflagellates" level={get_readings(@readings, "eui-70b3d57ed00493cd", 1)}
          temperature={get_readings(@readings, "eui-70b3d57ed00493cd", 6)} min_temperature={10} max_temperature={30}
          />
        <Tank x={600} y={200} width={50} height={100}
          max_level={200} min_level={0} label="Vegetables" level={get_readings(@readings, "eui-70b3d57ed0049476", 1)}
          temperature={get_readings(@readings, "eui-70b3d57ed0049476", 6)} min_temperature={10} max_temperature={30}
          />
        <Cloud x={360} y={25}
          temperature={get_readings(@readings, "eui-70b3d57ed00493cd", 2)}
          humidity={get_readings(@readings, "eui-70b3d57ed00493cd", 3)}/>
      </svg>
    """
  end

  defp get_readings(readings, observer_id, sensor_type), do: Map.get(readings, {observer_id, sensor_type})
end
