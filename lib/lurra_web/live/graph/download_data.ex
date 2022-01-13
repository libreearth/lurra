defmodule LurraWeb.Graph.DownloadData do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.DateTimeLocalInput
  alias Surface.Components.Link

  alias LurraWeb.Router.Helpers, as: Routes

  prop time, :integer, required: true
  prop timezone, :string, required: true
  prop device_id, :string, required: true
  prop sensor_type, :string, required: true

  def update(assigns, socket) do
    from = get_from(assigns.time, assigns.timezone)
    to = get_to(assigns.timezone)

    {
      :ok,
      socket
      |> assign(:from, from)
      |> assign(:to, to)
      |> assign(:device_id, assigns.device_id)
      |> assign(:sensor_type, assigns.sensor_type)
      |> assign(:timezone, assigns.timezone)
      |> assign(:download_url, build_url(assigns.device_id, assigns.sensor_type, from, to, assigns.timezone))
    }
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("change", %{"dates" => %{"from" => from, "to" => to}}, socket) do
    pfrom = parse_date(from, socket.assigns.timezone)
    pto = parse_date(to, socket.assigns.timezone)

    {
      :noreply,
      socket
      |> assign(:from, pfrom)
      |> assign(:to, pto)
      |> assign(:download_url, build_url(socket.assigns.device_id, socket.assigns.sensor_type, pfrom, pto, socket.assigns.timezone))
    }
  end

  defp parse_date(text_date, timezone) do
    Timex.parse!(text_date, "{YYYY}-{M}-{D}T{h24}:{m}")
    |> Timex.to_datetime(timezone)
  end

  defp get_from(time, timezone) do
    DateTime.utc_now()|> DateTime.add(-time, :millisecond) |> Timex.Timezone.convert(timezone)
  end

  defp get_to(timezone) do
    Timex.Timezone.convert(DateTime.utc_now(), timezone)
  end

  defp build_url(device_id, sensor_type, from, to, timezone) do
    Routes.download_data_path(LurraWeb.Endpoint, :index, device_id, sensor_type, from: DateTime.to_unix(from, :milliseconds), to: DateTime.to_unix(to, :milliseconds), timezone: timezone)
  end
end
