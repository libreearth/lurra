defmodule LurraWeb.Components.WaterMeter do
  @moduledoc """
  A Water Meter Component
  """
  use Surface.Component

  @doc "Water pressure value mm"
  prop value, :integer

  @doc "The name"
  prop name, :string, default: "M1"

  @doc "The Device EUI"
  prop device, :string

  @doc "The status"
  prop status, :string, values!: ["connected", "iddle", "disconnected"]

  def render(assigns) do
    ~F"""
    <div class="tank">
      <div class="water" style={value_to_percentage_style(:water, @value)}"></div>
    </div>
    <h5>{@value} mm</h5>
    """
  end

  defp value_to_percentage_style(sensor_type, value) do
    IO.puts "value_to_perecentage_style"
    IO.inspect value
    IO.inspect sensor_type
    range = 3000

    percentage = (value / range) * 100
    "height: #{percentage}%;"
  end

  # Public API

  def update_value(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: "water_meter", value: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  # Event handlers

  def handle_event(event, other, socket) do
    IO.puts "water_meter handle event"
    IO.inspect event
    IO.inspect other
    {:noreply, socket}
  end

end
