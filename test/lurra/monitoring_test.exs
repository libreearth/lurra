defmodule Lurra.MonitoringTest do
  use Lurra.DataCase

  alias Lurra.Monitoring

  describe "sensors" do
    alias Lurra.Monitoring.Sensor

    import Lurra.MonitoringFixtures

    @invalid_attrs %{name: nil, sensor_type: nil, unit: nil, value_type: nil}

    test "list_sensors/0 returns all sensors" do
      sensor = sensor_fixture()
      assert Monitoring.list_sensors() == [sensor]
    end

    test "get_sensor!/1 returns the sensor with given id" do
      sensor = sensor_fixture()
      assert Monitoring.get_sensor!(sensor.id) == sensor
    end

    test "create_sensor/1 with valid data creates a sensor" do
      valid_attrs = %{name: "some name", sensor_type: 42, unit: "some unit", value_type: "some value_type"}

      assert {:ok, %Sensor{} = sensor} = Monitoring.create_sensor(valid_attrs)
      assert sensor.name == "some name"
      assert sensor.sensor_type == 42
      assert sensor.unit == "some unit"
      assert sensor.value_type == "some value_type"
    end

    test "create_sensor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monitoring.create_sensor(@invalid_attrs)
    end

    test "update_sensor/2 with valid data updates the sensor" do
      sensor = sensor_fixture()
      update_attrs = %{name: "some updated name", sensor_type: 43, unit: "some updated unit", value_type: "some updated value_type"}

      assert {:ok, %Sensor{} = sensor} = Monitoring.update_sensor(sensor, update_attrs)
      assert sensor.name == "some updated name"
      assert sensor.sensor_type == 43
      assert sensor.unit == "some updated unit"
      assert sensor.value_type == "some updated value_type"
    end

    test "update_sensor/2 with invalid data returns error changeset" do
      sensor = sensor_fixture()
      assert {:error, %Ecto.Changeset{}} = Monitoring.update_sensor(sensor, @invalid_attrs)
      assert sensor == Monitoring.get_sensor!(sensor.id)
    end

    test "delete_sensor/1 deletes the sensor" do
      sensor = sensor_fixture()
      assert {:ok, %Sensor{}} = Monitoring.delete_sensor(sensor)
      assert_raise Ecto.NoResultsError, fn -> Monitoring.get_sensor!(sensor.id) end
    end

    test "change_sensor/1 returns a sensor changeset" do
      sensor = sensor_fixture()
      assert %Ecto.Changeset{} = Monitoring.change_sensor(sensor)
    end
  end
end
