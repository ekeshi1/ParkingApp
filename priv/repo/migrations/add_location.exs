defmodule Parking.Repo.Migrations.AddLocation do
  use Ecto.Migration

  def change do
    alter table("parking_places") do
      add :lat, float
      add :long, float
    end
  end
end
