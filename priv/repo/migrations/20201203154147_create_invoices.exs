defmodule Parking.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :status, :string
      add :amount, :integer
      add :end_time, :utc_datetime
      add :start_time, :utc_datetime
      add :booking_id, references(:bookings)

      timestamps()
    end

  end
end
