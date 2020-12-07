defmodule ParkingWeb.UserIntegrationTest do
  use ParkingWeb.ConnCase

  alias Parking.Account
  alias Parking.Guardian

  setup do
    conn = build_conn()
      |> Guardian.Plug.sign_out()

    {:ok, conn: conn}
  end


  test "Unauth user should be redirected to login page", %{conn: conn} do
    conn = get(conn,"/")
    assert html_response(conn,302) =~ "/sessions/new"

  end

  test "Authenticated user should be sent to the search page", %{conn: conn} do
    Account.create_user(%{email: "bob@gmail.com", license: "356654", name: "some name", password: "123"})
    conn = post conn, "/sessions", %{session: [email: "bob@gmail.com", password: "123"]}
    assert Parking.Authentication.load_current_user(conn)
    conn = get(conn,"/")
    assert html_response(conn,302)=~"You are being <a href=\"/search\">redirected"

  end


  test "Authenticated user cant register", %{conn: conn} do
    Account.create_user(%{email: "bob2@gmail.com", license: "3566542", name: "some name", password: "123"})

    conn = post conn, "/sessions", %{session: [email: "bob2@gmail.com", password: "123"]}
    assert Parking.Authentication.load_current_user(conn)
    conn = get(conn, "/users/new")
    assert html_response(conn,302)=~"You are being <a href=\"/search\">redirected"
  end

  test "Authenticated users cant login", %{conn: conn} do
    Account.create_user(%{email: "bob3@gmail.com", license: "35665423", name: "some name", password: "123"})
    conn = post conn, "/sessions", %{session: [email: "bob3@gmail.com", password: "123"]}
    assert Parking.Authentication.load_current_user(conn)
    conn = get(conn, "/sessions/new")
    assert html_response(conn,302)=~"You are being <a href=\"/search\">redirected"
  end

  test "created user gets redirected to login page", %{conn: conn} do
    conn = post conn , "users", %{user: [email: "bob4@gmail.com", license: "123123",name: "Doesnt matter", password: "123"]}
    assert html_response(conn,302)=~"/sessions/new"
  end

end
