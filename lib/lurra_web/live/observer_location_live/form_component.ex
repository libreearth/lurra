defmodule LurraWeb.ObserverLocationLive.FormComponent do
  use Surface.LiveComponent

  alias Surface.Components.Form.{Label, Field, Select, Submit}
  alias Surface.Components.Form
  alias Lurra.EcoOases
  alias Lurra.Monitoring
  alias LurraWeb.Router.Helpers, as: Routes
  alias LurraWeb.Endpoint

  prop observer, :map, required: true

  def update(%{observer: observer} = _assigns, socket) do
    original_eco_oasis = find_eco_oasis(observer)
    {
      :ok,
      socket
      |> assign(:observer, observer)
      |> assign(:location, create_location(observer))
      |> assign(:elements, eco_oasis_selector(original_eco_oasis))
      |> assign(:original_eco_oasis, original_eco_oasis)
      |> assign(:eco_oases, Lurra.EcoOases.list_eco_oases() |> Enum.map(& {&1.name, &1.id}))
    }
  end

  def handle_event("change", %{"observer_location" => params}, socket) do
    eco_oasis = EcoOases.get_eco_oasis!(String.to_integer(params["eco_oasis"]))
    {
      :noreply,
      socket
      |> assign(:elements, eco_oasis_selector(eco_oasis))
    }
  end

  def handle_event("save",  %{"observer_location" => params}, socket) do
    case save_changes(params, socket.assigns.observer.id) do
      :ok ->
        reload_eco_oasis(socket.assigns.original_eco_oasis)
        reload_eco_oasis(params["eco_oasis"] |> string_to_int())
        {:noreply,
         socket
         |> put_flash(:info, "Observer updated successfully")
         |> push_redirect(to: Routes.observer_location_index_path(Endpoint, :index))}

      {:error, message} ->
        {
          :noreply,
          socket |> put_flash(:info, message)
        }
    end
  end

  defp reload_eco_oasis(nil), do: nil
  defp reload_eco_oasis(id) when is_integer(id), do: Lurra.Core.EcoOasis.Server.ServerSupervisor.reload_eco_oasis(id)
  defp reload_eco_oasis(%Lurra.EcoOases.EcoOasis{id: id}), do: Lurra.Core.EcoOasis.Server.ServerSupervisor.reload_eco_oasis(id)

  defp save_changes(params, observer_id) do
    params
    |> Map.delete("eco_oasis")
    |> Enum.map(fn {sensor_id, element_id} -> save_location(observer_id, sensor_id, element_id) end)
    |> List.first()
  end

  defp save_location(observer_id, sensor_id, element_id) do
    sensor_id = string_to_int(sensor_id)
    element_id = string_to_int(element_id)
    Monitoring.update_observer_and_sensor_element(observer_id, sensor_id, element_id)
  end

  defp create_location(observer) do
    for sensor <- observer.sensors, into: %{} do
      {"#{sensor.id}", value_of_element(observer.id, sensor.id)}
    end
    |> Map.put("eco_oasis", find_eco_oasis_id(observer))
  end

  defp find_eco_oasis_id(observer) do
    observer.sensors
    |> Enum.map( fn sensor -> EcoOases.get_element_by_observer_and_sensor(observer.id, sensor.id) end)
    |> Enum.filter(& not is_nil(&1))
    |> List.first()
    |> nget(:eco_oasis_id)
  end

  defp find_eco_oasis(observer) do
    find_eco_oasis_id(observer) |> query_eco_oasis()
  end

  defp value_of_element(observer_id, sensor_id) do
    EcoOases.get_element_by_observer_and_sensor(observer_id, sensor_id) |> IO.inspect |> nget(:id) |> int_to_string()
  end

  defp nget(nil, _), do: nil
  defp nget(m, key), do: Map.get(m, key)

  defp int_to_string(nil), do: nil
  defp int_to_string(integer), do: Integer.to_string(integer)

  defp string_to_int(nil), do: nil
  defp string_to_int(""), do: nil
  defp string_to_int(str), do: String.to_integer(str)

  defp query_eco_oasis(nil), do: nil
  defp query_eco_oasis(eco_oasis_id), do: EcoOases.get_eco_oasis!(eco_oasis_id)

  defp eco_oasis_selector(nil), do: []
  defp eco_oasis_selector(eco_oasis), do:  Map.get(eco_oasis, :elements, []) |> Enum.map(& {&1.name, &1.id})
end
