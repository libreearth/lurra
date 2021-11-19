defmodule LurraWeb.Dashboard do
  use Surface.LiveView

  alias LurraWeb.Components.WaterMeter
  alias LurraWeb.Components.EcoObserver
  alias LurraWeb.Endpoint

  @events_topic "events"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@events_topic)
    end
    socket = socket
    |> assign(:value, 0)
    |> assign(:temperature, 0.0)
    |> assign(:lat, 0.0)
    |> assign(:long, 0.0)
    |> assign(:sats, 0)
    |> assign(:bme_temp, 0.0)
    |> assign(:bme_pressure, 0.0)
    |> assign(:bme_humidity, 0.0)

    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <div>
      <WaterMeter id="water_meter" value={@value} subtitle="How are you?" color="info"/>
      <EcoObserver id="water_temperature" bme_humidity={@bme_humidity} bme_pressure={@bme_pressure}  bme_temp={@bme_temp} temperature={@temperature} lat={@lat} long={@long} sats={@sats} subtitle="How are you?" color="info"/>
    </div>
    """
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 1}, topic: "events"} = event, socket) do
    IO.puts "type 1 payload"
    IO.inspect payload
    LurraWeb.Components.WaterMeter.update_value("water_meter", value: payload)
    {:noreply, assign(socket, :value, payload)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 6}, topic: "events"} = event, socket) do
    IO.puts "type 5 payload"
    IO.inspect payload
    temperature = payload
    LurraWeb.Components.EcoObserver.update_value("water_temperature", temperature: temperature)
    {:noreply, assign(socket, :temperature, temperature)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 7}, topic: "events"} = event, socket) do
    IO.puts "type 7 payload"
    IO.inspect payload
    {value , _} = Float.parse(payload)
    value = payload
    LurraWeb.Components.EcoObserver.update_lat("water_temperature", lat: value)
    {:noreply, assign(socket, :lat, value)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 8}, topic: "events"} = event, socket) do
    IO.puts "type 8 payload"
    IO.inspect payload
    {value , _} = Float.parse(payload)
    value = payload
    LurraWeb.Components.EcoObserver.update_long("water_temperature", long: value)
    {:noreply, assign(socket, :lat, value)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 2}, topic: "events"} = event, socket) do
    IO.puts "type 2 payload"
    IO.inspect payload
    value = payload
    LurraWeb.Components.EcoObserver.update_bme_temp("water_temperature", bme_temp: value)
    {:noreply, assign(socket, :bme_temp, value)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 3}, topic: "events"} = event, socket) do
    IO.puts "type 3 payload"
    IO.inspect payload
    value = payload
    LurraWeb.Components.EcoObserver.update_bme_humidity("water_temperature", bme_humidity: value)
    {:noreply, assign(socket, :bme_humidity, value)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 4}, topic: "events"} = event, socket) do
    IO.puts "type 3 payload"
    IO.inspect payload
    value = payload
    LurraWeb.Components.EcoObserver.update_bme_pressure("water_temperature", bme_pressure: value)
    {:noreply, assign(socket, :bme_pressure, value)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, type: 9}, topic: "events"} = event, socket) do
    IO.puts "type  9 payload"
    IO.inspect payload
    value = String.to_integer(payload)
    LurraWeb.Components.EcoObserver.update_sats("water_temperature", sats: value)
    {:noreply, assign(socket, :sats, value)}
  end




  # def handle_info(%{
  #   event: "event_created",
  #   payload: %{payload: payload, type: type},
  #   topic: "events"
  # } = event, socket) do
  #   IO.puts "handle event"
  #   IO.inspect payload
  #   IO.inspect type
  #   #send_update(SurveyResultsLive,id: socket.assigns.survey_results_component_id)

  #   {:noreply, socket}
  # end
end
