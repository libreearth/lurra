defmodule LurraWeb.WarningLiveTest do
  use LurraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lurra.EventsFixtures

  @create_attrs %{date: 42, description: "some description", device_id: "some device_id", sensor_type: 42}
  @update_attrs %{date: 43, description: "some updated description", device_id: "some updated device_id", sensor_type: 43}
  @invalid_attrs %{date: nil, description: nil, device_id: nil, sensor_type: nil}

  defp create_warning(_) do
    warning = warning_fixture()
    %{warning: warning}
  end

  describe "Index" do
    setup [:create_warning]

    test "lists all warnings", %{conn: conn, warning: warning} do
      {:ok, _index_live, html} = live(conn, Routes.warning_index_path(conn, :index))

      assert html =~ "Listing Warnings"
      assert html =~ warning.description
    end

    test "saves new warning", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.warning_index_path(conn, :index))

      assert index_live |> element("a", "New Warning") |> render_click() =~
               "New Warning"

      assert_patch(index_live, Routes.warning_index_path(conn, :new))

      assert index_live
             |> form("#warning-form", warning: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#warning-form", warning: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.warning_index_path(conn, :index))

      assert html =~ "Warning created successfully"
      assert html =~ "some description"
    end

    test "updates warning in listing", %{conn: conn, warning: warning} do
      {:ok, index_live, _html} = live(conn, Routes.warning_index_path(conn, :index))

      assert index_live |> element("#warning-#{warning.id} a", "Edit") |> render_click() =~
               "Edit Warning"

      assert_patch(index_live, Routes.warning_index_path(conn, :edit, warning))

      assert index_live
             |> form("#warning-form", warning: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#warning-form", warning: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.warning_index_path(conn, :index))

      assert html =~ "Warning updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes warning in listing", %{conn: conn, warning: warning} do
      {:ok, index_live, _html} = live(conn, Routes.warning_index_path(conn, :index))

      assert index_live |> element("#warning-#{warning.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#warning-#{warning.id}")
    end
  end

  describe "Show" do
    setup [:create_warning]

    test "displays warning", %{conn: conn, warning: warning} do
      {:ok, _show_live, html} = live(conn, Routes.warning_show_path(conn, :show, warning))

      assert html =~ "Show Warning"
      assert html =~ warning.description
    end

    test "updates warning within modal", %{conn: conn, warning: warning} do
      {:ok, show_live, _html} = live(conn, Routes.warning_show_path(conn, :show, warning))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Warning"

      assert_patch(show_live, Routes.warning_show_path(conn, :edit, warning))

      assert show_live
             |> form("#warning-form", warning: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#warning-form", warning: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.warning_show_path(conn, :show, warning))

      assert html =~ "Warning updated successfully"
      assert html =~ "some updated description"
    end
  end
end
