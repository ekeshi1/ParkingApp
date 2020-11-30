defmodule Parking.Places.Parking_place do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking_places" do
    field :name, :string
    field :address, :string
    field :total_places, :integer
    field :busy_places, :integer
    field :zone_id, :string
    field :lat, :float
    field :long, :float
    has_many :bookings, Parking.Bookings.Booking
    timestamps()
  end
  @doc false
  def changeset(parking_place, params  \\ %{}) do
    parking_place
    |> cast(params, [:name,:address,:total_places,:busy_places,:zone_id,:lat,:long])
    |> validate_required([:name,:address,:total_places,:busy_places,:zone_id,:lat,:long])
  end
end
