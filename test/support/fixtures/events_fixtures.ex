defmodule Lurra.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lurra.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        h3id: "some h3id",
        payload: "some payload",
        timestamp: ~U[2021-11-04 15:07:00Z],
        type: "some type"
      })
      |> Lurra.Events.create_event()

    event
  end

  @doc """
  Generate a warning.
  """
  def warning_fixture(attrs \\ %{}) do
    {:ok, warning} =
      attrs
      |> Enum.into(%{
        date: 42,
        description: "some description",
        device_id: "some device_id",
        sensor_type: 42
      })
      |> Lurra.Events.create_warning()

    warning
  end
end
