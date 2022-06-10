defmodule LurraWeb.Components.EcoObserverLocation do
  @moduledoc """
  This component represents a EcoObserver (Box with sensors) and
  presents the last readings into the screen
  """
  use Surface.Component

  alias LurraWeb.Router.Helpers, as: Routes
  alias Surface.Components.Link
  alias LurraWeb.Endpoint

  prop observer, :struct, required: true

  def get_oasis_name(observer) do
    Lurra.Monitoring.list_observer_sensor_by_observer(observer.id)
    |> Enum.find(fn os -> not is_nil(os.element_id) end)
    |> name_from_os()
  end

  defp name_from_os(nil), do: "-"
  defp name_from_os(os) do
    os
    |> Map.get(:element_id)
    |> Lurra.EcoOases.get_element!()
    |> Map.get(:eco_oasis_id)
    |> Lurra.EcoOases.get_eco_oasis!()
    |> Map.get(:name)
  end

  def get_element(observer, sensor) do
    case Lurra.EcoOases.get_element_by_observer_and_sensor(observer.id, sensor.id) do
      nil -> ""
      element -> element.name
    end
  end

  def format(input, _decimals) when is_binary(input) do
    input
  end

  def format(input, _decimals) when is_integer(input) do
    input
  end

  def format(input, nil) when is_float(input) do
    :erlang.float_to_binary(input, decimals: 2)
  end

  def format(input, decimals) when is_float(input) do
    :erlang.float_to_binary(input, decimals: decimals)
  end

end
