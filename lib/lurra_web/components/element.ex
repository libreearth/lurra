defmodule LurraWeb.Components.Element do
  @moduledoc """
  This component represents a Element of an EcoOasis (Box with sensors) and
  presents the last readings into the screen
  """
  use Surface.Component

  alias Surface.Components.Link
  alias LurraWeb.Router.Helpers, as: Routes

  prop element, :struct, required: true

  def format(nil, _decimals) do
    "No readings yet."
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
