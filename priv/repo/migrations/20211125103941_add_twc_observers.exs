defmodule Lurra.Repo.Migrations.AddTwcObservers do
  use Ecto.Migration

  def change do
    alter table(:observers) do
      add :type, :string
      add :api_key, :string
    end
    alter table(:sensors) do
      add :field_name, :string
    end
  end
end
