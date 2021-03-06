defmodule LurraWeb.WarningLive.Index do
  use LurraWeb, :live_view

  alias Lurra.Events
  alias Lurra.Events.Warning
  alias Lurra.Monitoring
  alias Lurra.Accounts

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    update_user_visit(user_token)
    {:ok, assign(socket, :warnings, list_warnings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Warning")
    |> assign(:warning, Events.get_warning!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Warning")
    |> assign(:warning, %Warning{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Warnings")
    |> assign(:warning, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    warning = Events.get_warning!(id)
    {:ok, _} = Events.delete_warning(warning)

    {:noreply, assign(socket, :warnings, list_warnings())}
  end

  defp list_warnings do
    Events.list_warnings_limit(100)
  end

  defp update_user_visit(user_token) do
    Accounts.get_user_by_session_token(user_token)
    |> Accounts.update_user(%{last_warning_visit: :erlang.system_time(:millisecond)})
  end
end
