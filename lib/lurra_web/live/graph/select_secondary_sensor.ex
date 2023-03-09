defmodule LurraWeb.Graph.SelectSecondarySensor do
  use Surface.LiveComponent

  alias Lurra.Monitoring
  alias Surface.Components.Form
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.Select
  alias Surface.Components.Form.Checkbox
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Label

  @separator "/~/@/~/"

  prop unit, :string, required: true

  def mount(socket) do
    {:ok, assign(socket, :only_archived, false)}
  end

  def handle_event("save", %{"selector" => %{"sensor" => sensor_to_add}}, socket) do
    LurraWeb.Components.Dialog.hide("add-secondary-sensor-dialog")
    [observer_id, sensor_type] = String.split(sensor_to_add, @separator)
    send(self(), {:add_sensor, observer_id, sensor_type})
    {:noreply, socket}
  end

  def handle_event("change", %{"selector" => %{"only_archived" => "true"}}, socket) do
    {:noreply, assign(socket, :only_archived, true)}
  end

  def handle_event("change", %{"selector" => %{"only_archived" => "false"}}, socket) do
    {:noreply, assign(socket, :only_archived, false)}
  end

  defp sensors_options(unit, archived) do
    Monitoring.list_observer_sensors_by_unit(unit, archived)
    |> Enum.map(fn {_os, observer, sensor} -> {"#{observer.name} - #{sensor.name}", "#{observer.device_id}#{@separator}#{sensor.sensor_type}"} end)
  end
end
