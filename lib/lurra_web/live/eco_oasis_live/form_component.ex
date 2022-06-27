defmodule LurraWeb.EcoOasisLive.FormComponent do
  use LurraWeb, :live_component

  alias Lurra.EcoOases
  alias Lurra.EcoOases.Element

  @types ["Tank", "Pond", "Slice", "Hexagon", "Vermifilter", "Soil", "Weather station"]

  @impl true
  def update(%{eco_oasis: eco_oasis} = assigns, socket) do
    changeset = EcoOases.change_eco_oasis(eco_oasis)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:types, @types)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"eco_oasis" => eco_oasis_params}, socket) do
    changeset =
      socket.assigns.eco_oasis
      |> EcoOases.change_eco_oasis(eco_oasis_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add-element", _, socket) do
    existing_elements = Map.get(socket.assigns.changeset.changes, :elements, socket.assigns.eco_oasis.elements)

    elements =
      existing_elements
      |> Enum.concat([
        %Element{temp_id: get_temp_id()}
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:elements, elements)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-element", %{"remove" => remove_id}, socket) do
    elements =
      socket.assigns.changeset.changes.elements
      |> Enum.reject(fn changeset ->
        Ecto.Changeset.get_change(changeset, :temp_id, nil) == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:elements, elements)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"eco_oasis" => eco_oasis_params}, socket) do
    save_eco_oasis(socket, socket.assigns.action, eco_oasis_params)
  end

  defp save_eco_oasis(socket, :edit, eco_oasis_params) do
    case EcoOases.update_eco_oasis(socket.assigns.eco_oasis, eco_oasis_params) do
      {:ok, eco_oasis} ->
        Lurra.Core.EcoOasis.Server.ServerSupervisor.reload_eco_oasis(eco_oasis.id)
        {:noreply,
         socket
         |> put_flash(:info, "Eco oasis updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_eco_oasis(socket, :new, eco_oasis_params) do
    case EcoOases.create_eco_oasis(eco_oasis_params) do
      {:ok, eco_oasis} ->
        Lurra.Core.EcoOasis.Server.ServerSupervisor.start_eco_oasis(eco_oasis.id)
        {:noreply,
         socket
         |> put_flash(:info, "Eco oasis created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)
end
