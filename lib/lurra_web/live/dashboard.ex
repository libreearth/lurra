defmodule LurraWeb.Dashboard do
  use Surface.LiveView

  import Lurra.TimezoneHelper

  alias LurraWeb.Components.EcoObserver
  alias LurraWeb.Endpoint
  alias LurraWeb.Components.DownloadDataForm
  alias LurraWeb.Components.Dialog
  alias Lurra.Accounts

  @events_topic "events"
  @last_warnings_limit 1000


  def mount(_params, %{"user_token" => user_token}, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@events_topic)
    end
    user = Accounts.get_user_by_session_token(user_token)
    observers = Lurra.Monitoring.list_observers_not_archived()
    socket = socket
    |> assign(:observers, observers)
    |> assign(:readings, initial_readings())
    |> assign(:warnings, Lurra.Events.list_warnings_limit(@last_warnings_limit))
    |> assign(:read_warnings_map, read_warnings_map(user))
    |> assign(:show_download_form, false)
    |> assign(:warnings_to_show, [])
    |> assign(:last_clicked_observer, nil)
    |> assign(:user, user)
    |> assign_timezone()

    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="dashboard-wrapper">
      {#if not @show_download_form}
        <div class="container upper-dashboard"><a class="to-right" phx-click="show_download_form"><i class="fa fa-download"/> Download sensors data</a></div>
        <div class="container dashboard">
          {#for box <- @observers}
            <EcoObserver
              show_checks={false}
              observer={box}
              readings={filter_device_readings(@readings, box.device_id)}
              warnings={filter_warnings(@warnings, @read_warnings_map, box.device_id)}/>
          {/for}
        </div>
      {#else}
        <div class="container">
            <a phx-click="hide_download_form" class="phx-modal-close">&times;</a>
            <DownloadDataForm id="download_form" timezone={@timezone} observers={@observers} readings={@readings}/>
        </div>
      {/if}
        <Dialog id="show-warnings-dialog" title="Warnings" show={false} hideEvent="close-show-warnings-dialog">
          <div class="warnings-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>Message</th>
                </tr>
              </thead>
              <tbody>
                {#for warning <- @warnings_to_show}
                  <tr>
                    <td>{format_date(warning.date, @timezone)}</td>
                    <td>{warning.description}</td>
                  </tr>
                {/for}
              </tbody>
            </table>
          </div>
          <div class="warnings-buttons">
            <button class="btn" phx-click="mark-warnings-as-read" phx-value-id={@last_clicked_observer}>Mark as read</button>
            <button class="btn btn-primary" phx-click="close-show-warnings-dialog">Close</button>
          </div>
        </Dialog>
    </div>
    """
  end

  def handle_event("mark-warnings-as-read", %{"id" => device_id}, socket) do
    LurraWeb.Components.Dialog.hide("show-warnings-dialog")
    Lurra.Accounts.mark_warnings_as_read(socket.assigns.user, device_id)
    {:noreply, push_event(socket, "reload", %{})}
  end

  def handle_event("show_warnings", %{"id" => device_id}, socket) do
    LurraWeb.Components.Dialog.show("show-warnings-dialog")
    warnings_to_show = Enum.filter(socket.assigns.warnings, fn warning -> warning.device_id == device_id end)
    {
      :noreply,
      socket
      |>assign(:warnings_to_show, warnings_to_show)
      |>assign(:last_clicked_observer, device_id)
    }
  end

  def handle_event("close-show-warnings-dialog", _params, socket) do
    LurraWeb.Components.Dialog.hide("show-warnings-dialog")
    {:noreply, socket}
  end

  def handle_event("show_download_form", _params, socket) do
    {:noreply, assign(socket, :show_download_form, true)}
  end

  def handle_event("hide_download_form", _params, socket) do
    {:noreply, assign(socket, :show_download_form, false)}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, device_id: device_id, type: type}, topic: "events"}, socket) do
    {
      :noreply,
      socket
      |> assign(:readings, Map.put(socket.assigns.readings, {device_id, type}, payload))
    }
  end

  def filter_device_readings(readings, device_id) do
    readings
    |> Enum.filter(fn {{dev_id, _type}, _payload} -> dev_id == device_id end)
    |> Enum.map(fn {{_device, type}, payload} -> {type, payload} end)
    |> Enum.into(%{})
  end

  def filter_warnings(warnings, read_warnings_map, device_id) do
    warnings
    |> Enum.filter(fn warning -> warning.device_id == device_id end)
    |> Enum.filter(fn warning -> Map.get(read_warnings_map, warning.device_id, 0) < warning.date end)
  end

  def initial_readings() do
    Lurra.Events.ReadingsCache.get_readings()
  end

  defp read_warnings_map(user) do
    ulows = Lurra.Accounts.get_user_last_observer_warning_visit(user)
    for %{device_id: device_id, timestamp: last_observed_at} <- ulows, into: %{} do
      {device_id, last_observed_at}
    end
  end
end
