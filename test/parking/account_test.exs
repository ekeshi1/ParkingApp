defmodule Parking.AccountTest do
  use Parking.DataCase

  alias Parking.Account

  describe "users" do
    alias Parking.Account.User

    @valid_attrs %{email: "e.d@hotmail.com", license: "some license", name: "some name", password: "some password"}
    @update_attrs %{email: "e.d@hotmail.com", license: "some updated license", name: "some updated name", password: "some updated password"}
    @invalid_attrs %{email: nil, license: nil, name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_user()

      user
    end


    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Account.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Account.create_user(@valid_attrs)
      assert user.email == "e.d@hotmail.com"
      assert user.license == "some license"
      assert user.name == "some name"
      assert user.password == "some password"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
    end


  end
end
