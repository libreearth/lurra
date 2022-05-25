defmodule LurraWeb.Components.DownloadDataForm do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.{Label, Field, DateTimeLocalInput, NumberInput}
  alias Surface.Components.Link
  alias LurraWeb.Components.EcoObserver

  alias LurraWeb.Router.Helpers, as: Routes


  @initial_time 60*60000

  prop timezone, :string, required: true
  prop observers, :list, required: true
  prop readings, :map, required: true
  data interval, :integer, default: 20
  data sensors, :list, default: []

  def update(assigns, socket) do
    from = Map.get(socket.assigns,:from) || get_from(@initial_time, assigns.timezone)
    to = Map.get(socket.assigns, :to) || get_to(assigns.timezone)
    {
      :ok,
      socket
      |> assign(:from, from)
      |> assign(:to, to)
      |> assign(:download_url, build_url(socket.assigns.sensors, from, to, socket.assigns.interval, assigns.timezone))
      |> assign(:observers, assigns.observers)
      |> assign(:readings, assigns.readings)
      |> assign(:timezone, assigns.timezone)
    }
  end

  def handle_event("change", %{"download" => %{"from" => from, "to" => to, "interval" => interval} = form_params}, socket) do
    pfrom = parse_date(from, socket.assigns.timezone)
    pto = parse_date(to, socket.assigns.timezone)
    sensors_list = build_sensors_list(form_params)
    {
      :noreply,
      socket
      |> assign(:from, pfrom)
      |> assign(:to, pto)
      |> assign(:download_url, build_url(sensors_list, pfrom, pto, socket.assigns.interval, socket.assigns.timezone))
      |> assign(:sensors, sensors_list)
      |> assign(:interval, interval)
    }
  end

  def filter_device_readings(readings, device_id) do
    readings
    |> Enum.filter(fn {{dev_id, _type}, _payload} -> dev_id == device_id end)
    |> Enum.map(fn {{_device, type}, payload} -> {type, payload} end)
    |> Enum.into(%{})
  end

  defp build_sensors_list(form_params) do
    form_params
    |> Map.keys()
    |> Enum.filter(& String.starts_with?(&1, "sensor"))
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

  defp build_url(sensors, from, to, interval, timezone) do
    Routes.download_multiple_data_path(LurraWeb.Endpoint, :index, interval: interval, sensors: sensors |> Enum.map(& String.replace(&1, "sensor-", "")) |> Enum.join(","), from: DateTime.to_unix(from, :milliseconds), to: DateTime.to_unix(to, :milliseconds), timezone: timezone)
  end

end
