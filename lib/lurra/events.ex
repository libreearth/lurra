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

  def stream_events(device_id, sensor_type, from_time, to_time) do
    query = from(e in Event, where: e.timestamp > ^from_time and e.timestamp < ^to_time and e.device_id == ^device_id and e.type == ^sensor_type, order_by: [asc: e.timestamp])
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


  def list_warnings_limit(limit) do
    query = from(e in Warning, limit: ^limit, order_by: [desc: e.date])
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

  def count_new_warnings(current_time) do
    Repo.one(from p in Warning, select: count(p.id), where: p.date > ^current_time)
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

  def list_lablogs_limit(limit) do
    query = from(e in Lablog, limit: ^limit, order_by: [desc: e.timestamp])
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

  def query_lablogs(from_time, to_time) do
    query = from(e in Lablog, where: e.timestamp > ^from_time and e.timestamp < ^to_time , order_by: [asc: e.timestamp])
    Repo.all(query)
  end
end
