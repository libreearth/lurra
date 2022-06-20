defmodule Lurra.EcoOasesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lurra.EcoOases` context.
  """

  @doc """
  Generate a eco_oasis.
  """
  def eco_oasis_fixture(attrs \\ %{}) do
    {:ok, eco_oasis} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Lurra.EcoOases.create_eco_oasis()

    eco_oasis
  end

  @doc """
  Generate a element.
  """
  def element_fixture(attrs \\ %{}) do
    {:ok, element} =
      attrs
      |> Enum.into(%{
        data: "some data",
        name: "some name",
        type: "some type"
      })
      |> Lurra.EcoOases.create_element()

    element
  end
end
