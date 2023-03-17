defmodule LurraWeb.Buoy.SelectPowerDialog do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.Select

  prop power, :number, required: true

  def handle_event("save", %{"selector" => %{"power" => power}}, socket) do
    LurraWeb.Components.Dialog.hide("power-dialog")
    send(self(), {:set_power, power})
    {:noreply, socket}
  end
end
