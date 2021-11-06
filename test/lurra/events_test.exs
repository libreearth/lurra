defmodule Lurra.EventsTest do
  use Lurra.DataCase

  alias Lurra.Events

  describe "events" do
    alias Lurra.Events.Event

    import Lurra.EventsFixtures

    @invalid_attrs %{h3id: nil, payload: nil, timestamp: nil, type: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{h3id: "some h3id", payload: "some payload", timestamp: ~U[2021-11-04 15:07:00Z], type: "some type"}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.h3id == "some h3id"
      assert event.payload == "some payload"
      assert event.timestamp == ~U[2021-11-04 15:07:00Z]
      assert event.type == "some type"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{h3id: "some updated h3id", payload: "some updated payload", timestamp: ~U[2021-11-05 15:07:00Z], type: "some updated type"}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.h3id == "some updated h3id"
      assert event.payload == "some updated payload"
      assert event.timestamp == ~U[2021-11-05 15:07:00Z]
      assert event.type == "some updated type"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
