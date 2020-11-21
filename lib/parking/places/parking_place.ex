defmodule Parking.Places.Parking_place do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking_places" do
    field :name, :string
    field :address, :string
    field :total_places, :integer
    field :busy_places, :integer
    belongs_to :zone, Parking.Places.Zone
    timestamps()
  end

  def changeset(struct, params ) do
    struct
    |> cast(params, [:name,:address,:total_places,:busy_places])
    |> validate_required([:name,:address,:total_places,:busy_places])
  end
end
