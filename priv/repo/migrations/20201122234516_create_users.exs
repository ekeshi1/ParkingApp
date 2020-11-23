defmodule Parking.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :license, :string
      add :password, :string

      timestamps()
    end

  end
end
