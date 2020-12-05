defmodule Parking.Repo.Migrations.AddRates do
  use Ecto.Migration

  def change do
    alter table("parametres") do
      add :hour_rate, :float
      add :realtime_rate, :float
    end

  end
end
