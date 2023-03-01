defmodule LurraWeb.Graph.SelectSecondarySensor do
  use Surface.LiveComponent

  alias Lurra.Monitoring
  alias Surface.Components.Form
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.Select

  @separator "/~/@/~/"

  prop unit, :string, required: true

  def handle_event("save", %{"selector" => [sensor_to_add]}, socket) do
    LurraWeb.Components.Dialog.hide("add-secondary-sensor-dialog")
    [observer_id, sensor_type] = String.split(sensor_to_add, @separator)
    send(self(), {:add_sensor, observer_id, sensor_type})
    {:noreply, socket}
  end

  defp sensors_options(unit) do
    Monitoring.list_observer_sensors_by_unit(unit)
    |> Enum.map(fn {_os, observer, sensor} -> {"#{observer.name} - #{sensor.name}", "#{observer.device_id}#{@separator}#{sensor.sensor_type}"} end)
  end
end
