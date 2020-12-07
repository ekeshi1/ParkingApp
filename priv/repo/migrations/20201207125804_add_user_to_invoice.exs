defmodule Parking.Repo.Migrations.AddUserToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :user_id, references(:users)
    end
  end
end
