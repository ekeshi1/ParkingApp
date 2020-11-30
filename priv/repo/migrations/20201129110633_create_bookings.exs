defmodule Parking.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :status, :string
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :total_amount, :float
      add :parking_type, :string
      add :user_id, references(:users)
      add :parking_place_id, references(:parking_places)
      timestamps()
    end

  end
end
