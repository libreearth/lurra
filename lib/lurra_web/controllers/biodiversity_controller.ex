defmodule LurraWeb.BiodiversityController do
  use LurraWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
