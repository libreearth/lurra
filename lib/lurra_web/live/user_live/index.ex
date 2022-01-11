defmodule LurraWeb.UserLive.Index do
  use LurraWeb, :live_view

  alias Lurra.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :users, Accounts.list_users())}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, assign(socket, :users, Accounts.list_users())}
  end

  def handle_event("confirm", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.confirm_user(user)

    {:noreply, assign(socket, :users, Accounts.list_users())}
  end


end
