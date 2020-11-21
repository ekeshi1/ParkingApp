defmodule Parking.Repo.Migrations.CreateParkingPlaces do
  use Ecto.Migration

  def change do
    create table("parking_places") do
      add :name, :string
      add :address, :string
      add :zone_id, references(:zones)
      add :total_places, :integer
      add :busy_places, :integer

      timestamps()
    end

    create unique_index(:parking_places, [:zone_id])
  end
end
