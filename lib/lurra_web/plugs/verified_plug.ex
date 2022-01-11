defmodule LurraWeb.VerifiedPlug do
  @moduledoc """
  This plug is used by controllers that wish to need a role to access them
  """
  import Plug.Conn
  alias LurraWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(%{assigns: %{current_user: %{confirmed_at: nil}}} = conn, _opts) do
    conn
    |> Phoenix.Controller.redirect(to: Routes.wait_confirmation_path(conn, :index))
    |> halt()
  end

  def call(%{assigns: %{current_user: %{confirmed_at: confirmation}}} = conn, _opts) when not is_nil(confirmation)  do
    conn
  end

  def call(conn, _opts) do
    conn
    |> send_resp(:unauthorized, "unauthorized")
    |> halt()
  end
end
