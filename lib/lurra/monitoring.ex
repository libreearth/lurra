defmodule Lurra.Monitoring do
  @moduledoc """
  The Monitoring context.
  """

  import Ecto.Query, warn: false
  alias Lurra.Repo

  alias Lurra.Monitoring.Sensor
  alias Lurra.Monitoring.ObserverSensor

  def list_sensors_at_element(element_id) do
    Repo.all(from os in ObserverSensor, where: os.element_id == ^element_id)
    |> Enum.map(fn os -> sensor_tuple(get_observer!(os.observer_id), get_sensor!(os.sensor_id), os.location_type) end)
  end

  defp sensor_tuple(observer, sensor, location_type), do: {observer.device_id, sensor.sensor_type, sensor.name, sensor.unit, sensor.precision, location_type}

  def list_observer_sensor_by_observer(observer_id) do
    Repo.all(from os in ObserverSensor, where: os.observer_id == ^observer_id)
  end

  def update_observer_and_sensor_element(observer_id, sensor_id, element_id, location_type) do
    case Repo.one!(from os in ObserverSensor, where: os.observer_id == ^observer_id and os.sensor_id == ^sensor_id) do
      nil ->
        nil
      observer_sensor ->
        case Repo.update(ObserverSensor.changeset(observer_sensor, %{element_id: element_id, location_type: location_type})) do
          {:ok, _} -> :ok
          error -> error
        end
    end
  end

  def get_sensor_by_type(type) do
    Repo.get_by(Sensor, sensor_type: type)
  end

  @doc """
  Returns the list of sensors.

  ## Examples

      iex> list_sensors()
      [%Sensor{}, ...]

  """
  def list_sensors do
    Repo.all(Sensor)
  end

  @doc """
  Gets a single sensor.

  Raises `Ecto.NoResultsError` if the Sensor does not exist.

  ## Examples

      iex> get_sensor!(123)
      %Sensor{}

      iex> get_sensor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sensor!(id), do: Repo.get!(Sensor, id)

  @doc """
  Creates a sensor.

  ## Examples

      iex> create_sensor(%{field: value})
      {:ok, %Sensor{}}

      iex> create_sensor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sensor(attrs \\ %{}) do
    %Sensor{}
    |> Sensor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sensor.

  ## Examples

      iex> update_sensor(sensor, %{field: new_value})
      {:ok, %Sensor{}}

      iex> update_sensor(sensor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sensor(%Sensor{} = sensor, attrs) do
    sensor
    |> Sensor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sensor.

  ## Examples

      iex> delete_sensor(sensor)
      {:ok, %Sensor{}}

      iex> delete_sensor(sensor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sensor(%Sensor{} = sensor) do
    Repo.delete(sensor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sensor changes.

  ## Examples

      iex> change_sensor(sensor)
      %Ecto.Changeset{data: %Sensor{}}

  """
  def change_sensor(%Sensor{} = sensor, attrs \\ %{}) do
    Sensor.changeset(sensor, attrs)
  end

  alias Lurra.Monitoring.Observer

  @doc """
  Returns the list of observers.

  ## Examples

      iex> list_observers()
      [%Observer{}, ...]

  """
  def list_observers do
    Repo.all(Observer)
    |> Enum.map(fn observer -> Repo.preload(observer, :sensors) end)
  end

  @doc """
  Gets a single observer.

  Raises `Ecto.NoResultsError` if the Observer does not exist.

  ## Examples

      iex> get_observer!(123)
      %Observer{}

      iex> get_observer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_observer!(id), do: Repo.get!(Observer, id) |> Repo.preload(:sensors)

  def get_observer_no_preload!(id), do: Repo.get!(Observer, id)

  def get_observer_by_device_id(device_id), do: Repo.get_by(Observer, device_id: device_id)

  def get_observer_by_device_id!(device_id), do: Repo.get_by!(Observer, device_id: device_id)

  def list_observers_by_type(type) do
    Repo.all(from c in Observer, where: c.type == ^type)
    |> Enum.map(fn observer -> Repo.preload(observer, :sensors) end)
  end

  @doc """
  Creates a observer.

  ## Examples

      iex> create_observer(%{field: value})
      {:ok, %Observer{}}

      iex> create_observer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_observer(attrs \\ %{}) do
    %Observer{}
    |> Observer.changeset(attrs)
    |> Repo.insert()
  end

  def create_observer(sensors, attrs) do
    %Observer{}
    |> Observer.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:sensors, sensors)
    |> Repo.insert()
  end

  @doc """
  Updates a observer.

  ## Examples

      iex> update_observer(observer, %{field: new_value})
      {:ok, %Observer{}}

      iex> update_observer(observer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_observer(%Observer{} = observer, attrs) do
    observer
    |> Observer.changeset(attrs)
    |> Repo.update()
  end

  def update_observer(sensors, %Observer{} = observer, attrs) do
    observer
    |> Observer.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:sensors, sensors)
    |> Repo.update()
  end

  @doc """
  Deletes a observer.

  ## Examples

      iex> delete_observer(observer)
      {:ok, %Observer{}}

      iex> delete_observer(observer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_observer(%Observer{} = observer) do
    Repo.delete(observer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking observer changes.

  ## Examples

      iex> change_observer(observer)
      %Ecto.Changeset{data: %Observer{}}

  """
  def change_observer(%Observer{} = observer, attrs \\ %{}) do
    Observer.changeset(observer, attrs)
  end
end
