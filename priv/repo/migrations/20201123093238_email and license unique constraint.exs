defmodule :"Elixir.Parking.Repo.Migrations.Email and license unique constraint" do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email, :license])
  end
end
