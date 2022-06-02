defmodule LurraWeb.WarningLive.FormComponent do
  use LurraWeb, :live_component

  alias Lurra.Events

  @impl true
  def update(%{warning: warning} = assigns, socket) do
    changeset = Events.change_warning(warning)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"warning" => warning_params}, socket) do
    changeset =
      socket.assigns.warning
      |> Events.change_warning(warning_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"warning" => warning_params}, socket) do
    save_warning(socket, socket.assigns.action, warning_params)
  end

  defp save_warning(socket, :edit, warning_params) do
    case Events.update_warning(socket.assigns.warning, warning_params) do
      {:ok, _warning} ->
        {:noreply,
         socket
         |> put_flash(:info, "Warning updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_warning(socket, :new, warning_params) do
    case Events.create_warning(warning_params) do
      {:ok, _warning} ->
        {:noreply,
         socket
         |> put_flash(:info, "Warning created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
