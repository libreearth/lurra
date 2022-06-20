defmodule Lurra.Repo.Migrations.AddPrecisionToSensors do
  use Ecto.Migration

  def change do
    alter table(:sensors) do
      add :precision, :integer
    end
  end
end
