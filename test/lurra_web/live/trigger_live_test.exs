defmodule LurraWeb.TriggerLiveTest do
  use LurraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lurra.TriggersFixtures

  @create_attrs %{actions: "some actions", device_id: "some device_id", name: "some name", rule: "some rule", sensor_type: 42}
  @update_attrs %{actions: "some updated actions", device_id: "some updated device_id", name: "some updated name", rule: "some updated rule", sensor_type: 43}
  @invalid_attrs %{actions: nil, device_id: nil, name: nil, rule: nil, sensor_type: nil}

  defp create_trigger(_) do
    trigger = trigger_fixture()
    %{trigger: trigger}
  end

  describe "Index" do
    setup [:create_trigger]

    test "lists all triggers", %{conn: conn, trigger: trigger} do
      {:ok, _index_live, html} = live(conn, Routes.trigger_index_path(conn, :index))

      assert html =~ "Listing Triggers"
      assert html =~ trigger.actions
    end

    test "saves new trigger", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.trigger_index_path(conn, :index))

      assert index_live |> element("a", "New Trigger") |> render_click() =~
               "New Trigger"

      assert_patch(index_live, Routes.trigger_index_path(conn, :new))

      assert index_live
             |> form("#trigger-form", trigger: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#trigger-form", trigger: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.trigger_index_path(conn, :index))

      assert html =~ "Trigger created successfully"
      assert html =~ "some actions"
    end

    test "updates trigger in listing", %{conn: conn, trigger: trigger} do
      {:ok, index_live, _html} = live(conn, Routes.trigger_index_path(conn, :index))

      assert index_live |> element("#trigger-#{trigger.id} a", "Edit") |> render_click() =~
               "Edit Trigger"

      assert_patch(index_live, Routes.trigger_index_path(conn, :edit, trigger))

      assert index_live
             |> form("#trigger-form", trigger: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#trigger-form", trigger: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.trigger_index_path(conn, :index))

      assert html =~ "Trigger updated successfully"
      assert html =~ "some updated actions"
    end

    test "deletes trigger in listing", %{conn: conn, trigger: trigger} do
      {:ok, index_live, _html} = live(conn, Routes.trigger_index_path(conn, :index))

      assert index_live |> element("#trigger-#{trigger.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#trigger-#{trigger.id}")
    end
  end

  describe "Show" do
    setup [:create_trigger]

    test "displays trigger", %{conn: conn, trigger: trigger} do
      {:ok, _show_live, html} = live(conn, Routes.trigger_show_path(conn, :show, trigger))

      assert html =~ "Show Trigger"
      assert html =~ trigger.actions
    end

    test "updates trigger within modal", %{conn: conn, trigger: trigger} do
      {:ok, show_live, _html} = live(conn, Routes.trigger_show_path(conn, :show, trigger))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Trigger"

      assert_patch(show_live, Routes.trigger_show_path(conn, :edit, trigger))

      assert show_live
             |> form("#trigger-form", trigger: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#trigger-form", trigger: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.trigger_show_path(conn, :show, trigger))

      assert html =~ "Trigger updated successfully"
      assert html =~ "some updated actions"
    end
  end
end
