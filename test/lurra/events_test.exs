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

  describe "warnings" do
    alias Lurra.Events.Warning

    import Lurra.EventsFixtures

    @invalid_attrs %{date: nil, description: nil, device_id: nil, sensor_type: nil}

    test "list_warnings/0 returns all warnings" do
      warning = warning_fixture()
      assert Events.list_warnings() == [warning]
    end

    test "get_warning!/1 returns the warning with given id" do
      warning = warning_fixture()
      assert Events.get_warning!(warning.id) == warning
    end

    test "create_warning/1 with valid data creates a warning" do
      valid_attrs = %{date: 42, description: "some description", device_id: "some device_id", sensor_type: 42}

      assert {:ok, %Warning{} = warning} = Events.create_warning(valid_attrs)
      assert warning.date == 42
      assert warning.description == "some description"
      assert warning.device_id == "some device_id"
      assert warning.sensor_type == 42
    end

    test "create_warning/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_warning(@invalid_attrs)
    end

    test "update_warning/2 with valid data updates the warning" do
      warning = warning_fixture()
      update_attrs = %{date: 43, description: "some updated description", device_id: "some updated device_id", sensor_type: 43}

      assert {:ok, %Warning{} = warning} = Events.update_warning(warning, update_attrs)
      assert warning.date == 43
      assert warning.description == "some updated description"
      assert warning.device_id == "some updated device_id"
      assert warning.sensor_type == 43
    end

    test "update_warning/2 with invalid data returns error changeset" do
      warning = warning_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_warning(warning, @invalid_attrs)
      assert warning == Events.get_warning!(warning.id)
    end

    test "delete_warning/1 deletes the warning" do
      warning = warning_fixture()
      assert {:ok, %Warning{}} = Events.delete_warning(warning)
      assert_raise Ecto.NoResultsError, fn -> Events.get_warning!(warning.id) end
    end

    test "change_warning/1 returns a warning changeset" do
      warning = warning_fixture()
      assert %Ecto.Changeset{} = Events.change_warning(warning)
    end
  end

  describe "lablogs" do
    alias Lurra.Events.Lablog

    import Lurra.EventsFixtures

    @invalid_attrs %{payload: nil, timestamp: nil, user: nil}

    test "list_lablogs/0 returns all lablogs" do
      lablog = lablog_fixture()
      assert Events.list_lablogs() == [lablog]
    end

    test "get_lablog!/1 returns the lablog with given id" do
      lablog = lablog_fixture()
      assert Events.get_lablog!(lablog.id) == lablog
    end

    test "create_lablog/1 with valid data creates a lablog" do
      valid_attrs = %{payload: "some payload", timestamp: ~U[2022-11-27 16:44:00Z], user: "some user"}

      assert {:ok, %Lablog{} = lablog} = Events.create_lablog(valid_attrs)
      assert lablog.payload == "some payload"
      assert lablog.timestamp == ~U[2022-11-27 16:44:00Z]
      assert lablog.user == "some user"
    end

    test "create_lablog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_lablog(@invalid_attrs)
    end

    test "update_lablog/2 with valid data updates the lablog" do
      lablog = lablog_fixture()
      update_attrs = %{payload: "some updated payload", timestamp: ~U[2022-11-28 16:44:00Z], user: "some updated user"}

      assert {:ok, %Lablog{} = lablog} = Events.update_lablog(lablog, update_attrs)
      assert lablog.payload == "some updated payload"
      assert lablog.timestamp == ~U[2022-11-28 16:44:00Z]
      assert lablog.user == "some updated user"
    end

    test "update_lablog/2 with invalid data returns error changeset" do
      lablog = lablog_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_lablog(lablog, @invalid_attrs)
      assert lablog == Events.get_lablog!(lablog.id)
    end

    test "delete_lablog/1 deletes the lablog" do
      lablog = lablog_fixture()
      assert {:ok, %Lablog{}} = Events.delete_lablog(lablog)
      assert_raise Ecto.NoResultsError, fn -> Events.get_lablog!(lablog.id) end
    end

    test "change_lablog/1 returns a lablog changeset" do
      lablog = lablog_fixture()
      assert %Ecto.Changeset{} = Events.change_lablog(lablog)
    end
  end
end
