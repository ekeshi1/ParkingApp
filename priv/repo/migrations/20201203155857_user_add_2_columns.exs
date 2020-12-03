defmodule Parking.Repo.Migrations.UserAdd2Columns do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :balance, :float
      add :monthly_payment, :bool
    end
  end
end
