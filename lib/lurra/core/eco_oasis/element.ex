defmodule Lurra.Core.Element do
  alias Lurra.Monitoring

  defstruct [:name, :type, measurements: %{}]

  def new(map) do
    %__MODULE__{
      name: map.name,
      type: map.type,
      measurements: create_measurements_map(map.id)
    }
  end

  defp create_measurements_map(element_id) do
    for {device_id, sensor_type, name, unit, precision} <- Monitoring.list_sensors_at_element(element_id), into: %{} do
      {{device_id, sensor_type}, {name, nil, unit, precision}}
    end
  end

end
