defmodule Lurra.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Lurra.Repo

  alias Lurra.Events.Event

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
end
