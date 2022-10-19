defmodule LurraWeb.ObserverLive.FormComponent do
  use LurraWeb, :live_component

  alias Lurra.Monitoring

  @impl true

  @types ["arduino box", "weather.com", "Wolkie Tolkie"]

  def update(%{observer: observer} = assigns, socket) do
    changeset = Monitoring.change_observer(observer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:show_sensors_dialog, false)
     |> assign(:sensors, Monitoring.list_sensors())
     |> assign(:box_sensors, observer.sensors)
     |> assign(:types, @types)
    }
  end

  @impl true
  def handle_event("show-sensors-dialog", %{}, socket) do
    {:noreply, assign(socket, :show_sensors_dialog, not socket.assigns.show_sensors_dialog)}
  end

  def handle_event("add-sensor", %{"sensor" => id_sensor}, socket) do
    sensor = Enum.find(socket.assigns.sensors, & &1.id == String.to_integer(id_sensor))
    {
      :noreply,
      socket
      |> assign(:box_sensors, [sensor | socket.assigns.box_sensors])
      |> assign(:show_sensors_dialog, false)
    }
  end

  def handle_event("delete-sensor", %{"sensor" => id_sensor}, socket) do
    {
      :noreply,
      socket
      |> assign(:box_sensors, Enum.filter(socket.assigns.box_sensors, & &1.id != String.to_integer(id_sensor)))
      |> assign(:show_sensors_dialog, false)
    }
  end

  def handle_event("validate", %{"observer" => observer_params}, socket) do
    changeset =
      socket.assigns.observer
      |> Monitoring.change_observer(observer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"observer" => observer_params}, socket) do
    save_observer(socket, socket.assigns.action, observer_params)
  end

  defp save_observer(socket, :edit, observer_params) do
    case Monitoring.update_observer(socket.assigns.box_sensors, socket.assigns.observer, observer_params) do
      {:ok, _observer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Observer updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_observer(socket, :new, observer_params) do
    case Monitoring.create_observer(socket.assigns.box_sensors, observer_params) do
      {:ok, _observer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Observer created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
