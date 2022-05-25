defmodule LurraWeb.Components.EcoObserver do
  @moduledoc """
  This component represents a EcoObserver (Box with sensors) and
  presents the last readings into the screen
  """
  use Surface.Component

  alias Surface.Components.Link
  alias LurraWeb.Router.Helpers, as: Routes
  alias Surface.Components.Form.Checkbox

  prop observer, :struct, required: true
  prop readings, :map, required: true
  prop show_checks, :boolean, required: true
  prop sensors_checked, :list, required: false, default: []

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
