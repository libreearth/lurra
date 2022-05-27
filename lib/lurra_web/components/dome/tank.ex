defmodule LurraWeb.Components.Dome.Tank do
  use Surface.Component


  @width 30
  @height 150

  prop x, :number, required: true
  prop y, :number, required: true

  def render(assigns) do
    ~F"""
      <rect x={@x} y={@y} width={@width} height={@height}/>
    """
  end
end
