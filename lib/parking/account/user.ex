defmodule Parking.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :license, :string
    field :name, :string
    field :password, :string

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :license, :password])
    |> validate_required([:name, :email, :license, :password])
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i, message: "Invalid email!" )
    |> unique_constraint(:email, message: "A user already exists with this email!")
    |> unique_constraint(:license, message: "A user already exists with this license!")
  end
end
