defmodule Lurra.Core.Element do
  alias Lurra.Monitoring

  defstruct [:id, :name, :type, measurements: %{}, data: %{}]

  def new(map, index) do
    %__MODULE__{
      id: map.id,
      name: map.name,
      type: map.type,
      measurements: create_measurements_map(map.id),
      data: create_data_map(map.data, index)
    }
  end

  defp create_data_map(nil, index), do: %{"location" => "A#{index}"}
  defp create_data_map("", index), do: %{"location" => "A#{index}"}
  defp create_data_map(data, _index) do
    Jason.decode!(data)
  end

  defp create_measurements_map(element_id) do
    for {device_id, sensor_type, name, unit, precision, location_type} <- Monitoring.list_sensors_at_element(element_id), into: %{} do
      {{device_id, sensor_type}, {name, nil, unit, precision, location_type}}
    end
  end

end
