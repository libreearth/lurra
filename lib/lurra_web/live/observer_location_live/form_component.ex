defmodule LurraWeb.ObserverLocationLive.FormComponent do
  use Surface.LiveComponent

  @location_types ["Water level", "Water temperature", "Air temperature", "Air humidity", "Pump"]

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
      |> assign(:location_types, @location_types)
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
    |> Enum.filter(fn {key, _} -> key_is_integer?(key) end)
    |> Enum.map(fn {sensor_id, element_id} -> save_location(observer_id, sensor_id, element_id, params["location_type_#{sensor_id}"]) end)
    |> List.first()
  end

  defp key_is_integer?(key) do
    case Integer.parse(key) do
      {_val, ""} -> true
      :error -> false
    end
  end

  defp save_location(observer_id, sensor_id, element_id, location_type) do
    sensor_id = string_to_int(sensor_id)
    element_id = string_to_int(element_id)
    Monitoring.update_observer_and_sensor_element(observer_id, sensor_id, element_id, location_type)
  end

  defp create_location(observer) do
    observer
    |> create_location_elements()
    |> create_locations(observer)
    |> Map.put("eco_oasis", find_eco_oasis_id(observer))
  end

  defp create_location_elements(observer) do
    for sensor <- observer.sensors, into: %{} do
      {"#{sensor.id}", value_of_element(observer.id, sensor.id)}
    end
  end

  defp create_locations(map, observer) do
    for sensor <- observer.sensors, into: map do
      {"location_type_#{sensor.id}", location_of_element(observer.id, sensor.id)}
    end
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
    EcoOases.get_element_by_observer_and_sensor(observer_id, sensor_id) |> nget(:id) |> int_to_string()
  end

  defp location_of_element(observer_id, sensor_id) do
    EcoOases.get_location_by_observer_and_sensor(observer_id, sensor_id)
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
