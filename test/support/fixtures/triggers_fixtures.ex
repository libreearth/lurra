defmodule Lurra.TriggersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lurra.Triggers` context.
  """

  @doc """
  Generate a trigger.
  """
  def trigger_fixture(attrs \\ %{}) do
    {:ok, trigger} =
      attrs
      |> Enum.into(%{
        actions: "some actions",
        device_id: "some device_id",
        name: "some name",
        rule: "some rule",
        sensor_type: 42
      })
      |> Lurra.Triggers.create_trigger()

    trigger
  end
end
