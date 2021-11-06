defmodule LurraWeb.SensorLiveTest do
  use LurraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lurra.MonitoringFixtures

  @create_attrs %{name: "some name", sensor_type: 42, unit: "some unit", value_type: "some value_type"}
  @update_attrs %{name: "some updated name", sensor_type: 43, unit: "some updated unit", value_type: "some updated value_type"}
  @invalid_attrs %{name: nil, sensor_type: nil, unit: nil, value_type: nil}

  defp create_sensor(_) do
    sensor = sensor_fixture()
    %{sensor: sensor}
  end

  describe "Index" do
    setup [:create_sensor]

    test "lists all sensors", %{conn: conn, sensor: sensor} do
      {:ok, _index_live, html} = live(conn, Routes.sensor_index_path(conn, :index))

      assert html =~ "Listing Sensors"
      assert html =~ sensor.name
    end

    test "saves new sensor", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.sensor_index_path(conn, :index))

      assert index_live |> element("a", "New Sensor") |> render_click() =~
               "New Sensor"

      assert_patch(index_live, Routes.sensor_index_path(conn, :new))

      assert index_live
             |> form("#sensor-form", sensor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sensor-form", sensor: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sensor_index_path(conn, :index))

      assert html =~ "Sensor created successfully"
      assert html =~ "some name"
    end

    test "updates sensor in listing", %{conn: conn, sensor: sensor} do
      {:ok, index_live, _html} = live(conn, Routes.sensor_index_path(conn, :index))

      assert index_live |> element("#sensor-#{sensor.id} a", "Edit") |> render_click() =~
               "Edit Sensor"

      assert_patch(index_live, Routes.sensor_index_path(conn, :edit, sensor))

      assert index_live
             |> form("#sensor-form", sensor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sensor-form", sensor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sensor_index_path(conn, :index))

      assert html =~ "Sensor updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes sensor in listing", %{conn: conn, sensor: sensor} do
      {:ok, index_live, _html} = live(conn, Routes.sensor_index_path(conn, :index))

      assert index_live |> element("#sensor-#{sensor.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sensor-#{sensor.id}")
    end
  end

  describe "Show" do
    setup [:create_sensor]

    test "displays sensor", %{conn: conn, sensor: sensor} do
      {:ok, _show_live, html} = live(conn, Routes.sensor_show_path(conn, :show, sensor))

      assert html =~ "Show Sensor"
      assert html =~ sensor.name
    end

    test "updates sensor within modal", %{conn: conn, sensor: sensor} do
      {:ok, show_live, _html} = live(conn, Routes.sensor_show_path(conn, :show, sensor))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Sensor"

      assert_patch(show_live, Routes.sensor_show_path(conn, :edit, sensor))

      assert show_live
             |> form("#sensor-form", sensor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#sensor-form", sensor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sensor_show_path(conn, :show, sensor))

      assert html =~ "Sensor updated successfully"
      assert html =~ "some updated name"
    end
  end
end
