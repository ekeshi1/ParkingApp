defmodule Parking.Places.Parametre do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parametres" do
    field :address, :string
    field :busy_places, :integer
    field :distance, :float
    field :hour_price, :float
    field :name, :string
    field :realtime_price, :float
    field :total_places, :integer
    field :zone_id, :string
    field :hour_rate, :float
    field :realtime_rate, :float
    timestamps()
  end

  @doc false
  def changeset(parametre, attrs) do
    parametre
    |> cast(attrs, [:name, :address, :zone_id, :busy_places, :hour_price, :realtime_price, :distance, :total_places, :realtime_rate, :hour_rate])
    |> validate_required([:name, :address, :zone_id, :busy_places, :hour_price, :realtime_price, :distance, :total_places, :realtime_rate, :hour_rate])
  end
end
