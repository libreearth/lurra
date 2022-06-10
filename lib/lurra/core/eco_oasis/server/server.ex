defmodule Lurra.Core.EcoOasis.Server do
  use GenServer

  alias LurraWeb.Endpoint
  alias Lurra.Core.Element
  alias Lurra.Core.EcoOasis

  @events_topic "events"

  def start_link(oasis_id) do
    GenServer.start_link(__MODULE__, oasis_id, name:  {:via, Registry, {Registry.EcoOasis, "oasis_#{oasis_id}"}})
  end

  def init(oasis_id) do
    oasis = load_oasis(oasis_id)
    Endpoint.subscribe(@events_topic)
    {:ok, oasis}
  end

  def handle_call(:get_eco_oasis, _from, oasis) do
    {:reply, oasis, oasis}
  end

  def handle_cast({:reload, id}, _oasis) do
    {:noreply, load_oasis(id)}
  end


  def handle_info(%Phoenix.Socket.Broadcast{event: "event_created", payload: %{device_id: device_id, payload: payload, type: sensor_type}, topic: @events_topic}, oasis) do
    {
      :noreply,
      %EcoOasis{ oasis | elements: recalculate_elements(oasis.elements, device_id, sensor_type, payload) }
    }
  end

  defp recalculate_elements(elements, device_id, sensor_type, payload) do
    for element <- elements do
      key = {device_id, sensor_type}
      if Map.has_key?(element.measurements, key) do
        %Element{element | measurements: Map.put(element.measurements, key, payload)}
      else
        element
      end
    end
  end

  defp load_oasis(oasis_id) do
    Lurra.EcoOases.get_eco_oasis!(oasis_id)
    |> to_structs()
  end

  defp to_structs(eco_oasis) do
    Lurra.Core.EcoOasis.new(eco_oasis)
  end

end
