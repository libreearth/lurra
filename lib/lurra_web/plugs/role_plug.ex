defmodule LurraWeb.RolePlug do
  @moduledoc """
  This plug is used by controllers that wish to need a role to access them
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(%{assigns: %{current_user: %{role: role}}} = conn, [role: role]) do
    conn
  end

  def call(conn, _opts) do
    conn
    |> send_resp(:unauthorized, "unauthorized")
    |> halt()
  end
end
