defmodule Lurra.Repo do
  use Ecto.Repo,
    otp_app: :lurra,
    adapter: Ecto.Adapters.Postgres
end
