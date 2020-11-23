defmodule ParkingWeb.SessionControllerTest do
  use ParkingWeb.ConnCase

  describe "log in" do

    test "log in succesful", %{conn: conn} do
      Account.create_user(%{email: "bob@gmail.com", license: "356654", name: "some name", password: "123"})
      conn = post conn, "/sessions/create", %{session: [email: "bob@gmail.com", password: "123"]}
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/Successfully logged in/
    end

    test "log in unsuccesful (no such user)", %{conn: conn} do
      conn = post conn, "/sessions/create", %{session: [email: "gary@gmail.com", password: "123"]}
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/User doesn't exist/
    end

    test "log in unsuccesful (wrong password)", %{conn: conn} do
      Account.create_user(%{email: "a@gmail.com", license: "123213", name: "some name", password: "123"})
      conn = post conn, "/sessions/create", %{session: [email: "a@gmail.com", password: "999"]}
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/Wrong password! Please try again/
    end
  end

end
