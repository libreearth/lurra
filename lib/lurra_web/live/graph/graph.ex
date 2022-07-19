defmodule LurraWeb.Graph do
  use Surface.LiveView

  alias Lurra.Monitoring
  alias Lurra.Events
  alias LurraWeb.Endpoint
  alias Surface.Components.Link
  alias Surface.Components.Form
  alias Surface.Components.Form.Select
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias LurraWeb.Components.Dialog
  alias LurraWeb.Graph.DownloadData
  alias LurraWeb.Graph.VerticalLimits


  @events_topic "events"
  @time_options [{"60 minutes", 60*60000}, {"120 minutes", 120*60000}, {"12 hours", 12*60*60000}, {"24 hours", 24*60*60000}, {"48 hours", 48*60*60000}, {"72 hours", 72*60*60000}]
  @default_timezone "UTC"

  def mount(%{"device_id" => device_id, "sensor_type" => sensor_type}, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@events_topic)
    end
    graph = Lurra.Graphs.get_graph(device_id, sensor_type)
    sensor = Monitoring.get_sensor_by_type(sensor_type)
    {
      :ok,
      socket
      |> assign(:observer, Monitoring.get_observer_by_device_id(device_id))
      |> assign(:sensor, sensor)
      |> assign(:time_options, @time_options)
      |> assign(:time, @time_options |> List.first() |> elem(1))
      |> assign(:mode, "play")
      |> assign(:max_value, graph_max(graph, sensor))
      |> assign(:min_value, graph_min(graph, sensor))
      |> assign_timezone()
    }
  end

  defp graph_max(nil, sensor), do: sensor.max_val
  defp graph_max(graph, _sensor), do: graph.max_value

  defp graph_min(nil, sensor), do: sensor.min_val
  defp graph_min(graph, _sensor), do: graph.min_value

  defp assign_timezone(socket) do
    timezone = get_connect_params(socket)["timezone"] || @default_timezone
    assign(socket, timezone: timezone)
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, device_id: device_id, type: type}, topic: "events"}, socket) do
    if (device_id == socket.assigns.observer.device_id and type == socket.assigns.sensor.sensor_type) do
      point = %{"time" => :erlang.system_time(:millisecond), "value" => payload}
      {:noreply, push_event(socket, "new-point", point)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:graph_updated, socket) do
    graph = Lurra.Graphs.get_graph(socket.assigns.observer.device_id, socket.assigns.sensor.sensor_type)
    {
      :noreply,
      socket
      |> assign(:max_value, graph_max(graph, socket.assigns.sensor))
      |> assign(:min_value, graph_min(graph, socket.assigns.sensor))
      |> push_event("update-chart", %{})
    }
  end

  def handle_event("time-change", %{"time" => %{"time_window" => miliseconds}}, socket) do
    {:noreply, assign(socket, :time, String.to_integer(miliseconds)) |> push_event("window-changed", %{time: miliseconds}) }
  end

  def handle_event("activate-mode-explore", _params, socket) do
    {:noreply, assign(socket, :mode, "explore")
    |> push_event("activate-mode-explore", %{})}
  end

  def handle_event("activate-mode-play", _params, socket) do
    {:noreply,  assign(socket, :mode, "play")
    |> push_event("activate-mode-play", %{})}
  end

  def handle_event("arrow-left", _params, socket) do
    {:noreply, push_event(socket, "arrow-left", %{})}
  end

  def handle_event("arrow-right", _params, socket) do
    {:noreply,  push_event(socket, "arrow-right", %{})}
  end


  def handle_event("map-created", %{"from_time" => from_time, "to_time" => to_time}, socket) do
    events = Events.list_events(socket.assigns.observer.device_id, "#{socket.assigns.sensor.sensor_type}", from_time, to_time)
    {:reply, %{"events" => events |> Enum.map(fn event -> %{"time" => event.timestamp, "value" => parse_float(event.payload)} end)}, socket}
  end

  def handle_event("show-download-dialog", _params, socket) do
    LurraWeb.Components.Dialog.show("download-data-dialog")
    {:noreply, socket}
  end

  def handle_event("close-download-dialog", _params, socket) do
    LurraWeb.Components.Dialog.hide("download-data-dialog")
    {:noreply, socket}
  end

  def handle_event("show-vertical-dialog", _params, socket) do
    LurraWeb.Components.Dialog.show("vertical-limits-dialog")
    {:noreply, socket}
  end

  def handle_event("close-vertical-dialog", _params, socket) do
    LurraWeb.Components.Dialog.hide("vertical-limits-dialog")
    {:noreply,socket}
  end

  defp parse_float(text) do
    {n, _} = Float.parse(text)
    n
  end
end
