defmodule LurraWeb.Components.Dome.Cloud do
  use Surface.Component

  prop x, :number, required: true
  prop y, :number, required: true
  prop temperature, :number, required: true
  prop humidity, :number, required: true

  def render(assigns) do
    ~F"""
      <g class="cloud" transform={"translate(#{@x} #{@y})"}>
        <g transform="translate(-83 -100) scale(0.23 0.23)">
          <path d="m 465.83684,466.9869 c -18.8823,0 -37.6499,7.7751 -51.0017,21.127 -8.4122,8.4121 -14.6043,18.9734 -18.0383,30.3583 -8.2539,1.5581 -16.0492,5.5866 -21.9931,11.5304 -7.7473,7.7473 -12.2573,18.6331 -12.2573,29.5895 0,10.9565 4.51,21.8458 12.2573,29.5931 7.7474,7.7473 18.6367,12.2573 29.5931,12.2573 l 187.4365,0 c 6.9935,0 13.9453,-2.8775 18.8904,-7.8224 4.9452,-4.9451 7.8227,-11.8971 7.8227,-18.8906 0,-6.9935 -2.8775,-13.9417 -7.8227,-18.8868 -4.9147,-4.9149 -11.8119,-7.784 -18.7617,-7.8193 -1.3562,-12.6709 -7.0967,-24.867 -16.1148,-33.8851 -10.3847,-10.3847 -24.9798,-16.4314 -39.666,-16.4314 -3.5656,0 -7.1233,0.3656 -10.6192,1.0539 -2.5582,-3.8175 -5.4715,-7.3951 -8.7235,-10.6469 -13.3518,-13.3519 -32.1193,-21.127 -51.0017,-21.127 z"/>
        </g>
        <text x="10" y="25">
          {temperature_text(@temperature)}
        </text>
        <text x="10" y ="35">
          {humidity_text(@humidity)}
        </text>
      </g>
    """
  end

  defp temperature_text(nil), do: ""
  defp temperature_text(temperature), do: "#{:erlang.float_to_binary(temperature, decimals: 1)} °C"

  defp humidity_text(nil), do: ""
  defp humidity_text(temperature), do: "#{:erlang.float_to_binary(temperature, decimals: 1)} %"
end
