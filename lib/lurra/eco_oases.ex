defmodule Lurra.EcoOases do
  @moduledoc """
  The EcoOases context.
  """

  import Ecto.Query, warn: false
  alias Lurra.Repo

  alias Lurra.EcoOases.EcoOasis
  alias Lurra.Monitoring.ObserverSensor

  def get_element_by_observer_and_sensor(observer_id, sensor_id) do
    case Repo.one!(from os in ObserverSensor, where: os.observer_id == ^observer_id and os.sensor_id == ^sensor_id) |> Map.get(:element_id) do
      nil -> nil
      element_id ->
        get_element!(element_id)
    end
  end

  def get_location_by_observer_and_sensor(observer_id, sensor_id) do
    Repo.one!(from os in ObserverSensor, where: os.observer_id == ^observer_id and os.sensor_id == ^sensor_id) |> Map.get(:location_type)
  end

  @doc """
  Returns the list of eco_oases.

  ## Examples

      iex> list_eco_oases()
      [%EcoOasis{}, ...]

  """
  def list_eco_oases do
    Repo.all(from q in EcoOasis, order_by: q.id)
  end

  def list_eco_oases_id do
    Repo.all(from q in EcoOasis, select: q.id, order_by: q.id)
  end

  @doc """
  Gets a single eco_oasis.

  Raises `Ecto.NoResultsError` if the Eco oasis does not exist.

  ## Examples

      iex> get_eco_oasis!(123)
      %EcoOasis{}

      iex> get_eco_oasis!(456)
      ** (Ecto.NoResultsError)

  """
  def get_eco_oasis!(id), do: Repo.get!(EcoOasis, id) |> Repo.preload(:elements)

  @doc """
  Creates a eco_oasis.

  ## Examples

      iex> create_eco_oasis(%{field: value})
      {:ok, %EcoOasis{}}

      iex> create_eco_oasis(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_eco_oasis(attrs \\ %{}) do
    %EcoOasis{}
    |> EcoOasis.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a eco_oasis.

  ## Examples

      iex> update_eco_oasis(eco_oasis, %{field: new_value})
      {:ok, %EcoOasis{}}

      iex> update_eco_oasis(eco_oasis, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_eco_oasis(%EcoOasis{} = eco_oasis, attrs) do
    eco_oasis
    |> EcoOasis.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a eco_oasis.

  ## Examples

      iex> delete_eco_oasis(eco_oasis)
      {:ok, %EcoOasis{}}

      iex> delete_eco_oasis(eco_oasis)
      {:error, %Ecto.Changeset{}}

  """
  def delete_eco_oasis(%EcoOasis{} = eco_oasis) do
    Repo.delete(eco_oasis)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking eco_oasis changes.

  ## Examples

      iex> change_eco_oasis(eco_oasis)
      %Ecto.Changeset{data: %EcoOasis{}}

  """
  def change_eco_oasis(%EcoOasis{} = eco_oasis, attrs \\ %{}) do
    EcoOasis.changeset(eco_oasis, attrs)
  end

  alias Lurra.EcoOases.Element

  @doc """
  Returns the list of elements.

  ## Examples

      iex> list_elements()
      [%Element{}, ...]

  """
  def list_elements do
    Repo.all(Element)
  end

  @doc """
  Gets a single element.

  Raises `Ecto.NoResultsError` if the Element does not exist.

  ## Examples

      iex> get_element!(123)
      %Element{}

      iex> get_element!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element!(id), do: Repo.get!(Element, id)

  @doc """
  Creates a element.

  ## Examples

      iex> create_element(%{field: value})
      {:ok, %Element{}}

      iex> create_element(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element(attrs \\ %{}) do
    %Element{}
    |> Element.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element.

  ## Examples

      iex> update_element(element, %{field: new_value})
      {:ok, %Element{}}

      iex> update_element(element, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element(%Element{} = element, attrs) do
    element
    |> Element.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element.

  ## Examples

      iex> delete_element(element)
      {:ok, %Element{}}

      iex> delete_element(element)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element(%Element{} = element) do
    Repo.delete(element)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element changes.

  ## Examples

      iex> change_element(element)
      %Ecto.Changeset{data: %Element{}}

  """
  def change_element(%Element{} = element, attrs \\ %{}) do
    Element.changeset(element, attrs)
  end
end
