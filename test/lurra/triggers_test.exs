defmodule Lurra.TriggersTest do
  use Lurra.DataCase

  alias Lurra.Triggers

  describe "triggers" do
    alias Lurra.Triggers.Trigger

    import Lurra.TriggersFixtures

    @invalid_attrs %{actions: nil, device_id: nil, name: nil, rule: nil, sensor_type: nil}

    test "list_triggers/0 returns all triggers" do
      trigger = trigger_fixture()
      assert Triggers.list_triggers() == [trigger]
    end

    test "get_trigger!/1 returns the trigger with given id" do
      trigger = trigger_fixture()
      assert Triggers.get_trigger!(trigger.id) == trigger
    end

    test "create_trigger/1 with valid data creates a trigger" do
      valid_attrs = %{actions: "some actions", device_id: "some device_id", name: "some name", rule: "some rule", sensor_type: 42}

      assert {:ok, %Trigger{} = trigger} = Triggers.create_trigger(valid_attrs)
      assert trigger.actions == "some actions"
      assert trigger.device_id == "some device_id"
      assert trigger.name == "some name"
      assert trigger.rule == "some rule"
      assert trigger.sensor_type == 42
    end

    test "create_trigger/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Triggers.create_trigger(@invalid_attrs)
    end

    test "update_trigger/2 with valid data updates the trigger" do
      trigger = trigger_fixture()
      update_attrs = %{actions: "some updated actions", device_id: "some updated device_id", name: "some updated name", rule: "some updated rule", sensor_type: 43}

      assert {:ok, %Trigger{} = trigger} = Triggers.update_trigger(trigger, update_attrs)
      assert trigger.actions == "some updated actions"
      assert trigger.device_id == "some updated device_id"
      assert trigger.name == "some updated name"
      assert trigger.rule == "some updated rule"
      assert trigger.sensor_type == 43
    end

    test "update_trigger/2 with invalid data returns error changeset" do
      trigger = trigger_fixture()
      assert {:error, %Ecto.Changeset{}} = Triggers.update_trigger(trigger, @invalid_attrs)
      assert trigger == Triggers.get_trigger!(trigger.id)
    end

    test "delete_trigger/1 deletes the trigger" do
      trigger = trigger_fixture()
      assert {:ok, %Trigger{}} = Triggers.delete_trigger(trigger)
      assert_raise Ecto.NoResultsError, fn -> Triggers.get_trigger!(trigger.id) end
    end

    test "change_trigger/1 returns a trigger changeset" do
      trigger = trigger_fixture()
      assert %Ecto.Changeset{} = Triggers.change_trigger(trigger)
    end
  end
end
