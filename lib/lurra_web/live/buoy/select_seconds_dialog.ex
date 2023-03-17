defmodule LurraWeb.Buoy.SelectSecondsDialog do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.TextInput

  prop freq, :number, required: true

  def handle_event("save", %{"selector" => %{"freq" => freq}}, socket) do
    LurraWeb.Components.Dialog.hide("freq-dialog")
    send(self(), {:set_freq, freq})
    {:noreply, socket}
  end
end
