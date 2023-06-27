defmodule Lurra.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Lurra.Repo

  alias Lurra.Events.Event

  @events_topic "events"

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  def list_events(device_id, sensor_type, from_time, to_time) do
    query = from(e in Event, where: e.timestamp > ^from_time and e.timestamp < ^to_time and e.device_id == ^device_id and e.type == ^sensor_type, order_by: [asc: e.timestamp])
    Repo.all(query)
  end

  def list_events_limit(limit) do
    query = from(e in Event, limit: ^limit, order_by: [desc: e.timestamp])
    Repo.all(query)
  end

  #SELECT e0."device_id", e0."type", avg(e0."payload"), min(e0."timestamp") FROM "events" AS e0 WHERE ((((e0."device_id" = '5aef5251-7158-4b56-b66c-e4e83fd8650d') AND (e0."type" = '15')) AND (e0."timestamp" >= 1671016502030)) AND (e0."timestamp" <= 1671020102030)) GROUP BY e0."timestamp" DIV 6000;
  def list_events_average(device_id, sensor_type, from_time, to_time, bin) do
    query =
      from(e in Event,
        where:
            e.device_id == ^device_id and e.type == ^sensor_type and e.timestamp >= ^from_time and
            e.timestamp <= ^to_time,
        select: %{
          device_id: ^device_id,
          type: ^sensor_type,
          payload_max: max(type(e.payload, :float)),
          payload_min: min(type(e.payload, :float)),
          timestamp: min(e.timestamp)
        },
        group_by: fragment("DIV(?,?)", e.timestamp, ^bin),
        order_by: min(e.timestamp)
      )
    Repo.all(query)
  end

  def stream_events(device_id, sensor_type, nil, nil, from_time, to_time) do
    query = from(e in Event, where: e.timestamp > ^from_time and e.timestamp < ^to_time and e.device_id == ^device_id and e.type == ^sensor_type, order_by: [asc: e.timestamp])
    Repo.stream(query)
  end

  def stream_events(device_id, sensor_type, sec_device_id, sec_sensor_type, from_time, to_time) do
    IO.inspect sec_device_id
    query = from(e in Event, where: e.timestamp > ^from_time and e.timestamp < ^to_time and ((e.device_id == ^device_id and e.type == ^sensor_type) or (e.device_id == ^sec_device_id and e.type == ^sec_sensor_type)), order_by: [asc: e.timestamp])
    Repo.stream(query)
  end

  def get_last_event(device_id, sensor_type) do
    st = "#{sensor_type}"
    query = from(
      e in Event,
      where: e.device_id == ^device_id and e.type == ^st,
      order_by: [desc: e.timestamp],
      limit: 1
    )
    Repo.all(query)
    |> List.first()
  end

  def get_last_events() do
    lasts = from(
      e in Event,
      select: max(e.id),
      group_by: [e.device_id, e.type]
    )

    query = from(
      e in Event,
      where: e.id in subquery(lasts)
    )
    Repo.all(query)
  end


  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def create_event_and_broadcast(value, device_id, sensor, epoch \\ :erlang.system_time(:millisecond)) do
    valid_attrs = %{payload: "#{value}", timestamp: epoch, device_id: device_id, type: "#{sensor.sensor_type}"}

    case Lurra.Events.create_event(valid_attrs) do
      {:ok, _event} ->
        state = %{ payload: value, device_id: device_id, type: sensor.sensor_type}
        LurraWeb.Endpoint.broadcast_from(self(), @events_topic, "event_created", state)
       nil
      error ->
       IO.inspect error
       nil
     end
  end

  def create_event(value, device_id, sensor_type, epoch \\ :erlang.system_time(:millisecond)) do
    valid_attrs = %{payload: "#{value}", timestamp: epoch, device_id: device_id, type: "#{sensor_type}"}

    case Lurra.Events.create_event(valid_attrs) do
      {:ok, _event} ->
       nil
      error ->
       IO.inspect error
       nil
     end
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  alias Lurra.Events.Warning

  @doc """
  Returns the list of warnings.

  ## Examples

      iex> list_warnings()
      [%Warning{}, ...]

  """
  def list_warnings do
    Repo.all(Warning)
  end


  @doc """
  Returns the list of warnings with a limit.
  """
  def list_warnings_limit(limit) do
    query = from(e in Warning, limit: ^limit, order_by: [desc: e.date])
    Repo.all(query)
  end

  @doc """
  Returns all the warnings different device_id
  """
  def list_warnings_distinct_device_id() do
    query = from(e in Warning, select: e.device_id, distinct: e.device_id, order_by: [desc: e.date])
    Repo.all(query)
  end

  @doc """
  Gets a single warning.

  Raises `Ecto.NoResultsError` if the Warning does not exist.

  ## Examples

      iex> get_warning!(123)
      %Warning{}

      iex> get_warning!(456)
      ** (Ecto.NoResultsError)

  """
  def get_warning!(id), do: Repo.get!(Warning, id)

  @doc """
  Creates a warning.

  ## Examples

      iex> create_warning(%{field: value})
      {:ok, %Warning{}}

      iex> create_warning(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_warning(attrs \\ %{}) do
    %Warning{}
    |> Warning.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Inserts a warning given a device_id and a message
  """
  def insert_warning(device_id, message) do
    valid_attrs = %{device_id: device_id, message: message, date: :erlang.system_time(:millisecond)}
    case Lurra.Events.create_warning(valid_attrs) do
      {:ok, _warning} ->
       nil
      error ->
       IO.inspect error
       nil
     end
  end

  @doc """
  Updates a warning.

  ## Examples

      iex> update_warning(warning, %{field: new_value})
      {:ok, %Warning{}}

      iex> update_warning(warning, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_warning(%Warning{} = warning, attrs) do
    warning
    |> Warning.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a warning.

  ## Examples

      iex> delete_warning(warning)
      {:ok, %Warning{}}

      iex> delete_warning(warning)
      {:error, %Ecto.Changeset{}}

  """
  def delete_warning(%Warning{} = warning) do
    Repo.delete(warning)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking warning changes.

  ## Examples

      iex> change_warning(warning)
      %Ecto.Changeset{data: %Warning{}}

  """
  def change_warning(%Warning{} = warning, attrs \\ %{}) do
    Warning.changeset(warning, attrs)
  end

  @doc """
  Returns the number of warnings newer than current_time.
  """
  def count_new_warnings(current_time) do
    Repo.one(from p in Warning, select: count(p.id), where: p.date > ^current_time)
  end

  @doc"""
  Returns the number of warnings not read of an user
  """
  def count_user_warnings(user) do
    user_id = user.id
    query = from(
      w in Warning,
      left_join: ul in Lurra.Account.UserLastObserverWarningVisit,
      on: w.device_id == ul.device_id and ul.user_id == ^user_id,
      where: w.date > ul.timestamp or is_nil(ul.timestamp),
      select: count(w.id)
    )
    Repo.one(query)
  end

  @doc """
  Returns the list of warnings newer than current_time.
  """
  def list_warnings_newer_than(current_time) do
    query = from(e in Warning, where: e.date > ^current_time, order_by: [desc: e.date])
    Repo.all(query)
  end

  alias Lurra.Events.Lablog

  @doc """
  Returns the list of lablogs.

  ## Examples

      iex> list_lablogs()
      [%Lablog{}, ...]

  """
  def list_lablogs do
    Repo.all(Lablog)
  end

  @doc """
  Returns the list of lablogs.
  """
  def list_lablogs_limit(limit) do
    query = from(e in Lablog, limit: ^limit, order_by: [desc: e.timestamp])
    Repo.all(query)
  end

  @doc """
  Returns the list of lablogs between from_time and to_time
  """
  def list_lablogs(from_time, to_time) do
    query = from(e in Lablog, where: e.timestamp > ^from_time and e.timestamp < ^to_time, order_by: [asc: e.timestamp])
    Repo.all(query)
  end

  @doc """
  Gets a single lablog.

  Raises `Ecto.NoResultsError` if the Lablog does not exist.

  ## Examples

      iex> get_lablog!(123)
      %Lablog{}

      iex> get_lablog!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lablog!(id), do: Repo.get!(Lablog, id)

  @doc """
  Creates a lablog.

  ## Examples

      iex> create_lablog(%{field: value})
      {:ok, %Lablog{}}

      iex> create_lablog(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lablog(attrs \\ %{}) do
    %Lablog{}
    |> Lablog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lablog.

  ## Examples

      iex> update_lablog(lablog, %{field: new_value})
      {:ok, %Lablog{}}

      iex> update_lablog(lablog, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lablog(%Lablog{} = lablog, attrs) do
    lablog
    |> Lablog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lablog.

  ## Examples

      iex> delete_lablog(lablog)
      {:ok, %Lablog{}}

      iex> delete_lablog(lablog)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lablog(%Lablog{} = lablog) do
    Repo.delete(lablog)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lablog changes.

  ## Examples

      iex> change_lablog(lablog)
      %Ecto.Changeset{data: %Lablog{}}

  """
  def change_lablog(%Lablog{} = lablog, attrs \\ %{}) do
    Lablog.changeset(lablog, attrs)
  end

  @doc """
  Returns the number of lablogs newer than current_time.
  """
  def query_lablogs(from_time, to_time) do
    query = from(e in Lablog, where: e.timestamp > ^from_time and e.timestamp < ^to_time , order_by: [asc: e.timestamp])
    Repo.all(query)
  end
end
