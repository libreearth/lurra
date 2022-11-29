defmodule LurraWeb.LablogLiveTest do
  use LurraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lurra.EventsFixtures

  @create_attrs %{payload: "some payload", timestamp: %{day: 27, hour: 16, minute: 44, month: 11, year: 2022}, user: "some user"}
  @update_attrs %{payload: "some updated payload", timestamp: %{day: 28, hour: 16, minute: 44, month: 11, year: 2022}, user: "some updated user"}
  @invalid_attrs %{payload: nil, timestamp: %{day: 30, hour: 16, minute: 44, month: 2, year: 2022}, user: nil}

  defp create_lablog(_) do
    lablog = lablog_fixture()
    %{lablog: lablog}
  end

  describe "Index" do
    setup [:create_lablog]

    test "lists all lablogs", %{conn: conn, lablog: lablog} do
      {:ok, _index_live, html} = live(conn, Routes.lablog_index_path(conn, :index))

      assert html =~ "Listing Lablogs"
      assert html =~ lablog.payload
    end

    test "saves new lablog", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.lablog_index_path(conn, :index))

      assert index_live |> element("a", "New Lablog") |> render_click() =~
               "New Lablog"

      assert_patch(index_live, Routes.lablog_index_path(conn, :new))

      assert index_live
             |> form("#lablog-form", lablog: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#lablog-form", lablog: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.lablog_index_path(conn, :index))

      assert html =~ "Lablog created successfully"
      assert html =~ "some payload"
    end

    test "updates lablog in listing", %{conn: conn, lablog: lablog} do
      {:ok, index_live, _html} = live(conn, Routes.lablog_index_path(conn, :index))

      assert index_live |> element("#lablog-#{lablog.id} a", "Edit") |> render_click() =~
               "Edit Lablog"

      assert_patch(index_live, Routes.lablog_index_path(conn, :edit, lablog))

      assert index_live
             |> form("#lablog-form", lablog: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#lablog-form", lablog: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.lablog_index_path(conn, :index))

      assert html =~ "Lablog updated successfully"
      assert html =~ "some updated payload"
    end

    test "deletes lablog in listing", %{conn: conn, lablog: lablog} do
      {:ok, index_live, _html} = live(conn, Routes.lablog_index_path(conn, :index))

      assert index_live |> element("#lablog-#{lablog.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lablog-#{lablog.id}")
    end
  end

  describe "Show" do
    setup [:create_lablog]

    test "displays lablog", %{conn: conn, lablog: lablog} do
      {:ok, _show_live, html} = live(conn, Routes.lablog_show_path(conn, :show, lablog))

      assert html =~ "Show Lablog"
      assert html =~ lablog.payload
    end

    test "updates lablog within modal", %{conn: conn, lablog: lablog} do
      {:ok, show_live, _html} = live(conn, Routes.lablog_show_path(conn, :show, lablog))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Lablog"

      assert_patch(show_live, Routes.lablog_show_path(conn, :edit, lablog))

      assert show_live
             |> form("#lablog-form", lablog: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#lablog-form", lablog: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.lablog_show_path(conn, :show, lablog))

      assert html =~ "Lablog updated successfully"
      assert html =~ "some updated payload"
    end
  end
end
