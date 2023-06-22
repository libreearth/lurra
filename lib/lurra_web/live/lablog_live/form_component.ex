defmodule LurraWeb.LablogLive.FormComponent do
  use LurraWeb, :live_component

  alias Lurra.Events
  import Lurra.TimezoneHelper

  @impl true
  def update(%{lablog: lablog, email: email} = assigns, socket) do
    changeset = Events.change_lablog(lablog)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:email, email)
    }
  end

  @impl true
  def handle_event("validate", %{"lablog" => lablog_params}, socket) do
    changeset =
      socket.assigns.lablog
      |> Events.change_lablog(lablog_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"lablog" => lablog_params}, socket) do
    save_lablog(socket, socket.assigns.action, lablog_params, socket.assigns.email, socket.assigns.timezone)
  end

  defp save_lablog(socket, :edit, lablog_params, _email, timezone) do
    lablog_params =
      lablog_params
      |> Map.put("timestamp", local_text_to_unix(lablog_params["timestamp"], timezone) )

    case Events.update_lablog(socket.assigns.lablog, lablog_params) do
      {:ok, _lablog} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lablog updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_lablog(socket, :new, lablog_params, email, timezone) do
    lablog_params =
      lablog_params
      |> Map.put("user", email)
      |> Map.put("timestamp", local_text_to_unix(lablog_params["timestamp"], timezone) )


    case Events.create_lablog(lablog_params) do
      {:ok, _lablog} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lablog created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
