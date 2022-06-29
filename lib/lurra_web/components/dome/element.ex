defmodule LurraWeb.Components.Dome.Element do
  use Surface.Component

  alias LurraWeb.Components.Dome.Tank

  prop element, :any, required: true

  def render(assigns) do
    ~F"""
    {#if is_nil(@element)}
      <svg class="tank"></svg>
    {#elseif @element.type == "Tank"}
      <Tank x={0} y={0} width={50} height={200}
        max_level={1600} min_level={1000} label={@element.name} level={get_measurement(@element, "Water level")}
        temperature={get_measurement(@element, "Water temperature")} air_temperature={get_measurement(@element, "Air temperature")}
        humidity={get_measurement(@element, "Air humidity")} min_temperature={10} max_temperature={30}
        />
    {#elseif @element.type == "Slice"}
      <Tank x={0} y={0} width={50} height={100}
        max_level={400} min_level={0} label={@element.name} level={get_measurement(@element, "Water level")}
        temperature={get_measurement(@element, "Water temperature")} air_temperature={get_measurement(@element, "Air temperature")}
        humidity={get_measurement(@element, "Air humidity")} min_temperature={10} max_temperature={30}
        />
    {/if}
    """
  end

  defp get_measurement(element, location_type) do
    Enum.find(element.measurements, fn {{_uid, _sensor_type}, {_name, _value, _units, _format, location}} -> location == location_type end)
    |> value()
  end

  defp value(nil), do: nil
  defp value({{_uid, _sensor_type}, {_name, value, _units, _format, _location}}), do: value
end
