defmodule ParkingWeb.PageControllerTest do
  use ParkingWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "You are being <a href=\"/sessions/new\">redirected"
  end
end
