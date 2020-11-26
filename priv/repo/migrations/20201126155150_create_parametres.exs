defmodule Parking.Repo.Migrations.CreateParametres do
  use Ecto.Migration

  def change do
    create table(:parametres) do
      add :name, :string
      add :address, :string
      add :zone_id, :string
      add :busy_places, :integer
      add :hour_price, :float
      add :realtime_price, :float
      add :distance, :float
      add :total_places, :integer

      timestamps()
    end

  end
end
