defmodule :"Elixir.Parking.Repo.Migrations.Fix unique" do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
    create unique_index(:users, [:license])

  end
end
