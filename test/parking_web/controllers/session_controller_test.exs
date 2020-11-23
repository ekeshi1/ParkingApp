defmodule ParkingWeb.SessionControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.Account
  alias Parking.Guardian

  setup do
    conn = build_conn()
      |> Guardian.Plug.sign_out()

    {:ok, conn: conn}
  end


  test "log in succesful", %{conn: conn} do
    Account.create_user(%{email: "bob@gmail.com", license: "356654", name: "some name", password: "123"})
    conn = post conn, "/sessions", %{session: [email: "bob@gmail.com", password: "123"]}
    assert Parking.Authentication.load_current_user(conn)
  end

  test "log in unsuccesful (no such user)", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "gary@gmail.com", password: "123"]}
    assert !Parking.Authentication.load_current_user(conn)
  end

  test "log in unsuccesful (wrong password)", %{conn: conn} do
    Account.create_user(%{email: "a@gmail.com", license: "123213", name: "some name", password: "123"})
    conn = post conn, "/sessions", %{session: [email: "a@gmail.com", password: "999"]}
    assert !Parking.Authentication.load_current_user(conn)
  end

  test "log out", %{conn: conn} do
    Account.create_user(%{email: "e@gmail.com", license: "3467", name: "some name", password: "123"})
    conn = post conn, "/sessions", %{session: [email: "e@gmail.com", password: "123"]}

    id = Parking.Authentication.load_current_user(conn).id
    conn = delete conn, "/sessions/#{id}", Parking.Authentication.load_current_user(conn)
    assert !Parking.Authentication.load_current_user(conn)
  end

end
