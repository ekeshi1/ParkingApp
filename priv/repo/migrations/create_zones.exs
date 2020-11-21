defmodule Takso.Repo.Migrations.CreateZones do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :name, :string
      add :hourly_rate, :float
      add :realtime_rate, :float

      timestamps()
    end

  end
end
