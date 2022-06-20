defmodule LurraWeb.EcoOasisLiveTest do
  use LurraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lurra.EcoOasesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_eco_oasis(_) do
    eco_oasis = eco_oasis_fixture()
    %{eco_oasis: eco_oasis}
  end

  describe "Index" do
    setup [:create_eco_oasis]

    test "lists all eco_oases", %{conn: conn, eco_oasis: eco_oasis} do
      {:ok, _index_live, html} = live(conn, Routes.eco_oasis_index_path(conn, :index))

      assert html =~ "Listing Eco oases"
      assert html =~ eco_oasis.name
    end

    test "saves new eco_oasis", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.eco_oasis_index_path(conn, :index))

      assert index_live |> element("a", "New Eco oasis") |> render_click() =~
               "New Eco oasis"

      assert_patch(index_live, Routes.eco_oasis_index_path(conn, :new))

      assert index_live
             |> form("#eco_oasis-form", eco_oasis: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#eco_oasis-form", eco_oasis: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.eco_oasis_index_path(conn, :index))

      assert html =~ "Eco oasis created successfully"
      assert html =~ "some name"
    end

    test "updates eco_oasis in listing", %{conn: conn, eco_oasis: eco_oasis} do
      {:ok, index_live, _html} = live(conn, Routes.eco_oasis_index_path(conn, :index))

      assert index_live |> element("#eco_oasis-#{eco_oasis.id} a", "Edit") |> render_click() =~
               "Edit Eco oasis"

      assert_patch(index_live, Routes.eco_oasis_index_path(conn, :edit, eco_oasis))

      assert index_live
             |> form("#eco_oasis-form", eco_oasis: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#eco_oasis-form", eco_oasis: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.eco_oasis_index_path(conn, :index))

      assert html =~ "Eco oasis updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes eco_oasis in listing", %{conn: conn, eco_oasis: eco_oasis} do
      {:ok, index_live, _html} = live(conn, Routes.eco_oasis_index_path(conn, :index))

      assert index_live |> element("#eco_oasis-#{eco_oasis.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#eco_oasis-#{eco_oasis.id}")
    end
  end

  describe "Show" do
    setup [:create_eco_oasis]

    test "displays eco_oasis", %{conn: conn, eco_oasis: eco_oasis} do
      {:ok, _show_live, html} = live(conn, Routes.eco_oasis_show_path(conn, :show, eco_oasis))

      assert html =~ "Show Eco oasis"
      assert html =~ eco_oasis.name
    end

    test "updates eco_oasis within modal", %{conn: conn, eco_oasis: eco_oasis} do
      {:ok, show_live, _html} = live(conn, Routes.eco_oasis_show_path(conn, :show, eco_oasis))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Eco oasis"

      assert_patch(show_live, Routes.eco_oasis_show_path(conn, :edit, eco_oasis))

      assert show_live
             |> form("#eco_oasis-form", eco_oasis: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#eco_oasis-form", eco_oasis: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.eco_oasis_show_path(conn, :show, eco_oasis))

      assert html =~ "Eco oasis updated successfully"
      assert html =~ "some updated name"
    end
  end
end
