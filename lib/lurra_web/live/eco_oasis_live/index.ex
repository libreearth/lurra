defmodule LurraWeb.EcoOasisLive.Index do
  use LurraWeb, :live_view

  alias Lurra.EcoOases
  alias Lurra.EcoOases.EcoOasis

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :eco_oases, list_eco_oases())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Eco oasis")
    |> assign(:eco_oasis, EcoOases.get_eco_oasis!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Eco oasis")
    |> assign(:eco_oasis, %EcoOasis{elements: []})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Eco oases")
    |> assign(:eco_oasis, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    eco_oasis = EcoOases.get_eco_oasis!(id)
    case EcoOases.delete_eco_oasis(eco_oasis) do
      {:ok, _} -> Lurra.Core.EcoOasis.Server.ServerSupervisor.kill_eco_oasis(eco_oasis.id)
      _ -> nil
    end

    {:noreply, assign(socket, :eco_oases, list_eco_oases())}
  end

  defp list_eco_oases do
    EcoOases.list_eco_oases()
  end
end
