defmodule LurraWeb.Components.Dome.Tank do
  use Surface.Component

  alias LurraWeb.Components.Dome.Cloud

  prop x, :number, required: true
  prop y, :number, required: true
  prop height, :number, required: true
  prop width, :number, required: true
  prop level, :number, required: true
  prop max_level, :number, required: true
  prop min_level, :number, required: true
  prop temperature, :number
  prop min_temperature, :number
  prop max_temperature, :number
  prop air_temperature, :number
  prop humidity, :number
  prop label, :string, required: true

  def render(assigns) do
    ~F"""
      <svg class="tank">
        {#if show_cloud(@air_temperature, @humidity)}
          <Cloud x={@x} y={@y} temperature={@air_temperature} humidity={@humidity}/>
        {/if}
        <g transform={"translate(0 #{250 - @height})"}>
          <text x={@x + 2} y={level_y(@y, @level, @max_level, @min_level, @height) - 2}>
            {@level} mm
          </text>
          <text class="title" transform={"rotate(90 #{@x + @width + 4} #{@y})"} x={@x + @width + 4} y={@y}>
            {@label}
          </text>
          {#if not is_nil(@level)}
            <rect x={@x} y={level_y(@y, @level, @max_level, @min_level, @height)} width={@width} height={level_width(@level, @max_level, @min_level, @height)} fill={temperature_color(@temperature, @max_temperature, @min_temperature)} class="tank-water"/>
          {/if}
            <rect x={@x} y={@y} width={@width} height={@height} class="tank-outline"/>
            <text x={@x + 2} y={text_y(@y, @height)} class="temperature">
              {temperature_text(@temperature)}
            </text>
        </g>
      </svg>
    """
  end

  defp show_cloud(temp, hum), do: not is_nil(temp) or not is_nil(hum)

  defp level_width(nil,  _max_level, _min_level, _height), do: 0.0
  defp level_width(level, max_level, min_level , height), do: height*(level-min_level)/(max_level-min_level)

  defp level_y(y, level, max_level, min_level, height), do: y + (height - level_width(level, max_level, min_level, height))

  defp text_y(y, height), do: y+height - 2

  defp temperature_color(nil, _max, _min), do: to_rgb(0, 0, 255)
  defp temperature_color(temperature, max, min) do
    p = (temperature-min)/(max-min)
    red = trunc(255*p)
    blue = trunc(255*(1-p))
    to_rgb(red, 0, blue)
  end

  defp to_rgb(red, green, blue) do
    "rgb(#{min(max(red, 0), 255)}, #{min(max(green, 0), 255)}, #{min(max(blue, 0), 255)})"
  end

  defp temperature_text(nil), do: ""
  defp temperature_text(temperature), do: "#{:erlang.float_to_binary(temperature, decimals: 1)} °C"
end
