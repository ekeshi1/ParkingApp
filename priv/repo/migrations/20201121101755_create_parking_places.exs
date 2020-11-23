defmodule Parking.Repo.Migrations.CreateParkingPlaces do
  use Ecto.Migration

  def change do
    create table("parking_places") do
      add :name, :string
      add :address, :string
      add :total_places, :integer
      add :busy_places, :integer
      add :zone_id, :string
      timestamps()
    end

  end
end
