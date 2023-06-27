defmodule LurraWeb.Graph do
  use Surface.LiveView

  import Lurra.TimezoneHelper

  alias Lurra.Monitoring
  alias Lurra.Events
  alias LurraWeb.Endpoint
  alias Surface.Components.Link
  alias Surface.Components.Form
  alias Surface.Components.Form.Select
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.NumberInput
  alias LurraWeb.Components.Dialog
  alias LurraWeb.Graph.DownloadData
  alias LurraWeb.Graph.VerticalLimits
  alias LurraWeb.Graph.Ruler
  alias LurraWeb.Graph.SelectSecondarySensor

  @events_topic "events"
  @time_options [
      {"60 minutes", 60*60000},
      {"120 minutes", 120*60000},
      {"6 hours", 6*60*60000},
      {"12 hours", 12*60*60000},
      {"24 hours", 24*60*60000},
      {"48 hours", 48*60*60000},
      {"72 hours", 72*60*60000},
      {"1 week", 7*24*60*60000},
      {"2 weeks", 2*7*24*60*60000},
      {"Custom...", 0}
    ]


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
      |> assign(:hours, 72)
      |> assign(:max_value, graph_max(graph, sensor))
      |> assign(:min_value, graph_min(graph, sensor))
      |> assign(:ruler_value, nil)
      |> assign(:sec_observer, %{device_id: nil, sensor_type: nil})
      |> assign_timezone()
    }
  end

  defp graph_max(nil, sensor), do: sensor.max_val
  defp graph_max(graph, _sensor), do: graph.max_value

  defp graph_min(nil, sensor), do: sensor.min_val
  defp graph_min(graph, _sensor), do: graph.min_value

  def render(assigns) do
    ~F"""
      <div class="container graph">
        <div  class="title-back"><Link label="Back" to={{:javascript, "history.back()"}} /></div>
          <div class="graph-title">
              <h2>{@observer.name} - {@sensor.name} </h2>
          </div>
          <div class="container">
              <div class="column centered-text">
                  <Form for={:time} change="time-change" submit="time-change" class="row-form">
                      <Field name="time_window">
                          <Label/><Select options={@time_options} opts={value: @time}/>
                      </Field>
                      <Field :if={@time==0} name="hours">
                          <Label/><NumberInput value={@hours} opts={step: :any}/>
                      </Field>
                  </Form>
              </div>
              <svg id="chart" :hook="Chart" data-minval={@min_value} data-maxval={@max_value} data-unit={@sensor.unit} data-rulerval={@ruler_value}></svg>
              <div class="graph-button">
                  <i class="fa fa-flask" :on-click="toogle-lablogs" title="Toogle lablogs"></i>
                  <i class="fa fa-plus" :on-click="show-add-secondary-sensor-dialog" title="Add secondary sensor"></i>
                  <i :if={@mode=="explore"} :on-click="arrow-left" class="fa fa-arrow-left" title="Move left"></i>
                  <i class="fa fa-ruler" :on-click="show-ruler-dialog" title="Set ruler"></i>
                  <i class="fa fa-download" :on-click="show-download-dialog" title="Download data"></i>
                  <i class="fa fa-arrows-v" :on-click="show-vertical-dialog" title="Vertical axis"></i>
                  <i :if={@mode=="explore"} :on-click="activate-mode-play" class="fa fa-play" title="Resume real time data"></i>
                  <i :if={@mode=="play"} :on-click="activate-mode-explore" class="fa fa-pause" title="Pause real time data"></i>
                  <i :if={@mode=="explore"} :on-click="arrow-right" class="fa fa-arrow-right" title="Move left"></i>
              </div>
          </div>
      </div>
      <Dialog id="download-data-dialog" title="Download data" show={false} hideEvent="close-download-dialog">
          <DownloadData id="download-data"
              time={@time}
              timezone={@timezone}
              device_id={@observer.device_id}
              sensor_type={@sensor.sensor_type}
              sec_device_id={@sec_observer.device_id}
              sec_sensor_type={@sec_observer.sensor_type}
              />
      </Dialog>
      <Dialog id="vertical-limits-dialog" title="Vertical limits" show={false} hideEvent="close-vertical-dialog">
          <VerticalLimits id="vertical-limits" max={@max_value} min={@min_value} device_id={@observer.device_id} sensor_type={@sensor.sensor_type}/>
      </Dialog>
      <Dialog id="ruler-dialog" title="Ruler value" show={false} hideEvent="close-ruler-dialog">
          <Ruler id="ruler" value={@ruler_value}/>
      </Dialog>
      <Dialog id="add-secondary-sensor-dialog" title="Select Secondary Sensor" show={false} hideEvent="close-add-secondary-sensor-dialog">
          <SelectSecondarySensor id="add-secondary-sensor" unit={@sensor.unit}/>
      </Dialog>
    """
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, device_id: device_id, type: type}, topic: "events"}, socket) do
    if (device_id == socket.assigns.observer.device_id and type == socket.assigns.sensor.sensor_type) do
      point = %{"time" => :erlang.system_time(:millisecond), "value" => payload}
      {:noreply, push_event(socket, "new-point", point)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:add_sensor, device_id, sensor_type}, socket) do
    observer = %{device_id: device_id, sensor_type: sensor_type}
    {
      :noreply,
      socket
      |> assign(:sec_observer, observer)
      |> push_event("add-secondary-data", observer)}
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

  def handle_info({:add_ruler, value}, socket) do
    {
      :noreply,
      socket
      |> assign(:ruler_value, value)
      |> push_event("update-chart", %{})
    }
  end

  def handle_event("toogle-lablogs", _params, socket) do
    {:noreply, socket |> push_event("toogle-lablogs", %{})}
  end

  def handle_event("time-change", %{"time" => %{"time_window" => "0", "hours" => hours}}, socket) do
    time = String.to_integer(hours)*60*60000
    {:noreply, socket |> assign(:hours, String.to_integer(hours)) |> push_event("window-changed", %{time: time}) }
  end

  def handle_event("time-change", %{"time" => %{"time_window" => "0"}}, socket) do
    {:noreply,  assign(socket, :time, 0)  |> assign(:hours, 72) |> push_event("window-changed", %{time: 72*60*60000}) }
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


  def handle_event("map-created", %{"sec_device_id" => sec_device_id, "sec_sensor_type" => sec_sensor_type, "from_time" => from_time, "to_time" => to_time, "bin" => bin}, socket) do
    events = Events.list_events_average(socket.assigns.observer.device_id, "#{socket.assigns.sensor.sensor_type}", from_time, to_time, bin)
    sec_events = Events.list_events_average(sec_device_id, sec_sensor_type, from_time, to_time, bin)
    lablogs = Events.list_lablogs(from_time, to_time)
    {
      :reply,
      %{
        "events" => events_to_map(events),
        "sec_events" => events_to_map(sec_events),
        "lablogs" => lablogs_to_map(lablogs)
      },
      socket
    }
  end

  def handle_event("map-created", %{"from_time" => from_time, "to_time" => to_time, "bin" => bin}, socket) do
    events = Events.list_events_average(socket.assigns.observer.device_id, "#{socket.assigns.sensor.sensor_type}", from_time, to_time, bin)
    lablogs = Events.list_lablogs(from_time, to_time)
    {
      :reply,
      %{
        "events" => events_to_map(events),
        "lablogs" => lablogs_to_map(lablogs)
      },
      socket
    }
  end

  def handle_event("show-download-dialog", _params, socket) do
    LurraWeb.Components.Dialog.show("download-data-dialog")
    {:noreply, socket}
  end

  def handle_event("show-ruler-dialog", _params, socket) do
    LurraWeb.Components.Dialog.show("ruler-dialog")
    {:noreply, socket}
  end

  def handle_event("show-add-secondary-sensor-dialog", _params, socket) do
    LurraWeb.Components.Dialog.show("add-secondary-sensor-dialog")
    {:noreply, socket}
  end

  def handle_event("close-add-secondary-sensor-dialog", _params, socket) do
    LurraWeb.Components.Dialog.hide("add-secondary-sensor-dialog")
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

  defp lablogs_to_map(lablogs), do: lablogs |> Enum.map(fn lablog -> %{"time" => lablog.timestamp, "user" => lablog.user, "payload" => lablog.payload} end)

  defp events_to_map(events) do
    events
      |> Enum.map(fn event -> [%{"time" => event.timestamp, "value" => parse_float(event.payload_min)}, %{"time" => event.timestamp, "value" => parse_float(event.payload_max)}] end)
      |> List.flatten()
  end

  defp parse_float(nil), do: 0
  defp parse_float(f) when is_float(f), do: f
  defp parse_float(text) do
    {n, _} = Float.parse(text)
    n
  end
end
