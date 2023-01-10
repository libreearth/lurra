defmodule Lurra.Core.BuoyData do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, []}
  end

  def handle_call({:register, uid}, _from, data) do
    create_ets_table_if_not_exists(uid)
    {:reply, uid, data}
  end

  def register(uid) do
    GenServer.call(__MODULE__, {:register, uid})
  end

  defp create_ets_table_if_not_exists(uid) do
    table = String.to_atom(uid)
    case :ets.whereis(table) do
      :undefined -> :ets.new(table, [:named_table, :ordered_set, :public])
      _ -> :undefined
    end
  end
end
