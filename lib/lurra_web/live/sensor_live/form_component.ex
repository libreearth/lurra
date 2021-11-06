defmodule LurraWeb.SensorLive.FormComponent do
  use LurraWeb, :live_component

  alias Lurra.Monitoring

  @impl true
  def update(%{sensor: sensor} = assigns, socket) do
    changeset = Monitoring.change_sensor(sensor)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"sensor" => sensor_params}, socket) do
    changeset =
      socket.assigns.sensor
      |> Monitoring.change_sensor(sensor_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"sensor" => sensor_params}, socket) do
    save_sensor(socket, socket.assigns.action, sensor_params)
  end

  defp save_sensor(socket, :edit, sensor_params) do
    case Monitoring.update_sensor(socket.assigns.sensor, sensor_params) do
      {:ok, _sensor} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sensor updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_sensor(socket, :new, sensor_params) do
    case Monitoring.create_sensor(sensor_params) do
      {:ok, _sensor} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sensor created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
