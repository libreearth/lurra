defmodule Lurra.MonitoringFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lurra.Monitoring` context.
  """

  @doc """
  Generate a sensor.
  """
  def sensor_fixture(attrs \\ %{}) do
    {:ok, sensor} =
      attrs
      |> Enum.into(%{
        name: "some name",
        sensor_type: 42,
        unit: "some unit",
        value_type: "some value_type"
      })
      |> Lurra.Monitoring.create_sensor()

    sensor
  end

  @doc """
  Generate a observer.
  """
  def observer_fixture(attrs \\ %{}) do
    {:ok, observer} =
      attrs
      |> Enum.into(%{
        device_id: "some device_id",
        name: "some name"
      })
      |> Lurra.Monitoring.create_observer()

    observer
  end
end
