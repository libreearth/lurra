defmodule LurraWeb.Components.EcoObserver do
  @moduledoc """
  A Water Meter Component
  """
  use Surface.Component

  import LurraWeb.Gettext

  @doc "Water pressure value mm"
  prop temperature, :integer
  prop bme_temp, :integer
  prop bme_humidity, :integer
  prop bme_pressure, :integer
  prop lat, :integer
  prop long, :integer
  prop sats, :integer

  @doc "The name"
  prop name, :string, default: "M1"

  @doc "The Device EUI"
  prop device, :string

  @doc "The status"
  prop status, :string, values!: ["connected", "iddle", "disconnected"]

  def render(assigns) do
    ~F"""
    <div class="air">
      <div class="temperature" style="">Out sensor temp: {@temperature}</div>
    </div>
    <div class="bme">
    <div class="temperature" style="">BME Temp: {@bme_temp}</div>
    <div class="pressure" style="">BME Pressure: {@bme_pressure}</div>
    <div class="humidity" style="">BME Humidity: {@bme_humidity}%</div>
  </div>
    <div class="gps">
      <div class="lat" style="">Latitude: {@lat}</div>
      <div class="long" style="">Longitude: {@long}</div>
      <div class="sats" style="">Satellites: {@sats}</div>
    </div>
    """
  end

  # Public API

  def update_value(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: sensor_id, temperature: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  def update_bme_temp(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: sensor_id, bme_temp: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  def update_bme_pressure(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: sensor_id, bme_pressure: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  def update_bme_humidity(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: sensor_id, bme_humidity: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  def update_lat(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: sensor_id, lat: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  def update_long(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: sensor_id, long: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  def update_sats(sensor_id, data) do
    IO.puts "update: #{sensor_id}"
    send_update(LurraWeb.Components.WaterMeter, id: sensor_id, sats: data)

    #send_update(__MODULE__, id: sensor_id, data: data)
  end

  # Event handlers

  def handle_event(event, other, socket) do
    IO.inspect event
    IO.inspect other
    {:noreply, socket}
  end

end
