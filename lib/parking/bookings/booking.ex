defmodule Parking.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :end_time, :utc_datetime
    field :start_time, :utc_datetime
    field :status, :string
    field :total_amount, :float
    belongs_to :user, Parking.Account.User
    belongs_to :parking_place, Parking.Places.Parking_place
    field :parking_type, :string #RT or H



    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:status, :start_time, :end_time, :total_amount,:parking_type])
    |> validate_required([:status, :start_time,:parking_type])
    |> validate_number(:end_time, greater_than: :start_time)

  end
end
