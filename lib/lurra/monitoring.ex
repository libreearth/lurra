defmodule Lurra.Monitoring do
  @moduledoc """
  The Monitoring context.
  """

  import Ecto.Query, warn: false
  alias Lurra.Repo

  alias Lurra.Monitoring.Sensor

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

  def get_observer_by_device_id(device_id), do: Repo.get_by!(Observer, device_id: device_id)

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
    |> IO.inspect
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
