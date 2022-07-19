defmodule LurraWeb.Graph.VerticalLimits do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.NumberInput
  alias Surface.Components.Form.Submit

  prop max, :number, required: true
  prop min, :number, required: true
  prop device_id, :string, required: true
  prop sensor_type, :integer, required: true

  def handle_event("save", %{"vertical_limits" => %{"max" => max, "min" => min}}, socket) do
    LurraWeb.Components.Dialog.hide("vertical-limits-dialog")
    Lurra.Graphs.save_graph(socket.assigns.device_id, socket.assigns.sensor_type, to_float(max), to_float(min))
    send(self(), :graph_updated)
    {:noreply, socket}
  end

  def handle_event("change", %{"vertical_limits" => %{"max" => _max, "min" => _min}}, socket) do
    {:noreply, socket}
  end

  defp to_float(bin) do
    {fl, _} = Float.parse(bin)
    fl
  end

end
