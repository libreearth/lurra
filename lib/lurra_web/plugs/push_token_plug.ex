defmodule LurraWeb.PushTokenPlug do
  @moduledoc """
  This plug is used by api controllers that wish to check the push token is present
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "token") do
      [token] ->
        if Application.fetch_env!(:lurra, :push_token) == token do
          conn
        else
          send_stop(conn)
        end
      _ ->
          send_stop(conn)
    end
  end

  defp send_stop(conn) do
    conn
    |> send_resp(:unauthorized, "unauthorized")
    |> halt()
  end
end
