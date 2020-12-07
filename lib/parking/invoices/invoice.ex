defmodule Parking.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :status, :string
    field :amount, :integer
    field :end_time, :utc_datetime
    field :start_time, :utc_datetime
    belongs_to :booking, Parking.Bookings.Booking
    belongs_to :user, Parking.Account.User

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:status, :amount, :end_time, :start_time])
    |> validate_required([:status, :amount, :end_time, :start_time])
  end
end
