defmodule Parking.Repo.Migrations.ChangeInvoiceAmountType do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      modify :amount, :float
    end
  end
end
