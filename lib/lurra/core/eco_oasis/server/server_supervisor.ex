defmodule Lurra.Core.EcoOasis.Server.ServerSupervisor do
  use DynamicSupervisor

  alias Lurra.Core.EcoOasis.Server

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def initial_eco_oasis() do
    Lurra.EcoOases.list_eco_oases_id()
    |> Enum.each(fn eco_oasis_id -> start_eco_oasis(eco_oasis_id) end)
  end

  def start_eco_oasis(eco_oasis_id) do
    DynamicSupervisor.start_child(__MODULE__, {Server, eco_oasis_id})
  end

  def kill_eco_oasis(eco_oasis_id) do
    DynamicSupervisor.terminate_child(__MODULE__, eco_oasis_pid(eco_oasis_id))
  end

  def reload_eco_oasis(eco_oasis_id) do
    GenServer.cast(eco_oasis_pid(eco_oasis_id), {:reload, eco_oasis_id})
  end

  def get_eco_oasis(eco_oasis_id) do
    GenServer.call(eco_oasis_pid(eco_oasis_id), :get_eco_oasis)
  end

  defp eco_oasis_id(eco_oasis_id), do: "oasis_#{eco_oasis_id}"

  def eco_oasis_pid(eco_oasis_id) do
    case Registry.lookup(Registry.EcoOasis, eco_oasis_id(eco_oasis_id)) do
      [{pid,_}] -> pid
      _ -> nil
    end
  end
end
