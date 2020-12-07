defmodule ParkingWeb.UserControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.Account.User
  alias Parking.Repo
  alias Parking.Account

  alias ParkingWeb.UserController


  @create_attrs %{email: "karl@gmail.com", license: "34567890", name: "some name", password: "123", monthly_payment: false}

  test "Configure monthly payment", %{conn: conn} do
    Account.create_user(@create_attrs)
    conn = post conn, "/sessions", %{session: [email: "karl@gmail.com", password: "123"]}

    user = Parking.Authentication.load_current_user(conn)
    conn = get(conn, Routes.user_path(conn, :edit, user))

    user = Account.get_user!(user.id)

    assert user.monthly_payment
  end

end
