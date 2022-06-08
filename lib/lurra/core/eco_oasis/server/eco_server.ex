defmodule Lurra.Core.EcoOasis.Server do
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

end
