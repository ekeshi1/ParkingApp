defmodule Parking.Places.Zone do
  use Ecto.Schema
  import Ecto.Changeset

  schema "zones" do
    field :name, :string
    field :hourly_rate, :float
    field :realtime_rate, :float
    timestamps()
  end

  def changeset(struct, params ) do
    struct
    |> cast(params, [:name,:hourly_rate,:realtime_rate])
    |> validate_required([:name,:hourly_rate,:realtime_rate])
  end
end
