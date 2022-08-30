defmodule LurraWeb.Graph.Ruler do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.NumberInput
  alias Surface.Components.Form.Submit

  prop value, :number, required: true

  def handle_event("save", %{"ruler" => %{"value" => value}}, socket) do
    LurraWeb.Components.Dialog.hide("ruler-dialog")
    send(self(), {:add_ruler, to_float(value)})
    {:noreply, socket}
  end

  def handle_event("change", %{"ruler" => %{"value" => _value}}, socket) do
    {:noreply, socket}
  end

  defp to_float(bin) do
    {fl, _} = Float.parse(bin)
    fl
  end

end
