defmodule LurraWeb.LablogLive.Index do
  use LurraWeb, :live_view

  import Lurra.TimezoneHelper

  alias Lurra.Events
  alias Lurra.Events.Lablog

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    %{email: email} = Lurra.Accounts.get_user_by_session_token(user_token)
    {
      :ok,
      socket
      |> assign( :lablogs, list_lablogs())
      |> assign( :email, email)
      |> assign_timezone()
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lablog")
    |> assign(:lablog, Events.get_lablog!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lablog")
    |> assign(:lablog, %Lablog{} |> Map.put(:timestamp, :erlang.system_time(:millisecond) ))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lablogs")
    |> assign(:lablog, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lablog = Events.get_lablog!(id)
    {:ok, _} = Events.delete_lablog(lablog)

    {:noreply, assign(socket, :lablogs, list_lablogs())}
  end

  defp list_lablogs do
    Events.list_lablogs_limit(400)
  end
end
