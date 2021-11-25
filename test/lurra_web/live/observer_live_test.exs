defmodule LurraWeb.ObserverLiveTest do
  use LurraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lurra.MonitoringFixtures

  @create_attrs %{device_id: "some device_id", name: "some name"}
  @update_attrs %{device_id: "some updated device_id", name: "some updated name"}
  @invalid_attrs %{device_id: nil, name: nil}

  defp create_observer(_) do
    observer = observer_fixture()
    %{observer: observer}
  end

  describe "Index" do
    setup [:create_observer]

    test "lists all observers", %{conn: conn, observer: observer} do
      {:ok, _index_live, html} = live(conn, Routes.observer_index_path(conn, :index))

      assert html =~ "Listing Observers"
      assert html =~ observer.device_id
    end

    test "saves new observer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.observer_index_path(conn, :index))

      assert index_live |> element("a", "New Observer") |> render_click() =~
               "New Observer"

      assert_patch(index_live, Routes.observer_index_path(conn, :new))

      assert index_live
             |> form("#observer-form", observer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#observer-form", observer: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.observer_index_path(conn, :index))

      assert html =~ "Observer created successfully"
      assert html =~ "some device_id"
    end

    test "updates observer in listing", %{conn: conn, observer: observer} do
      {:ok, index_live, _html} = live(conn, Routes.observer_index_path(conn, :index))

      assert index_live |> element("#observer-#{observer.id} a", "Edit") |> render_click() =~
               "Edit Observer"

      assert_patch(index_live, Routes.observer_index_path(conn, :edit, observer))

      assert index_live
             |> form("#observer-form", observer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#observer-form", observer: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.observer_index_path(conn, :index))

      assert html =~ "Observer updated successfully"
      assert html =~ "some updated device_id"
    end

    test "deletes observer in listing", %{conn: conn, observer: observer} do
      {:ok, index_live, _html} = live(conn, Routes.observer_index_path(conn, :index))

      assert index_live |> element("#observer-#{observer.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#observer-#{observer.id}")
    end
  end

  describe "Show" do
    setup [:create_observer]

    test "displays observer", %{conn: conn, observer: observer} do
      {:ok, _show_live, html} = live(conn, Routes.observer_show_path(conn, :show, observer))

      assert html =~ "Show Observer"
      assert html =~ observer.device_id
    end

    test "updates observer within modal", %{conn: conn, observer: observer} do
      {:ok, show_live, _html} = live(conn, Routes.observer_show_path(conn, :show, observer))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Observer"

      assert_patch(show_live, Routes.observer_show_path(conn, :edit, observer))

      assert show_live
             |> form("#observer-form", observer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#observer-form", observer: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.observer_show_path(conn, :show, observer))

      assert html =~ "Observer updated successfully"
      assert html =~ "some updated device_id"
    end
  end
end
