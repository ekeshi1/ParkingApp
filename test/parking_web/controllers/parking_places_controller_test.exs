defmodule ParkingWeb.ParkingPLacesControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.{Repo, Places.Parking_place, Places.Zone}
  alias Parking.Guardian

  @valid_attrs_with_everything %{destination_address: "Pikk 76, 50603, Tartu",hours: "2", minutes: "5" }
  @valid_attrs_without_time %{destination_address: "Pikk 76, 50603, Tartu",hours: "5", minutes: "5"}
  @valid_attrs_without_minutes%{destination_address: "Pikk 76, 50603, Tartu",hours: "6", minutes: "6"}
  @valid_attrs_without_hours%{destination_address: "Pikk 76, 50603, Tartu",hours: "1", minutes: "1"}

  setup do
    conn = build_conn()
      |> Guardian.Plug.sign_out()

    {:ok, conn: conn}
  end


  describe "search" do

    test "search with address, hours, and minutes", %{conn: conn} do

      conn = post conn, "/search/some", parking_place: @valid_attrs_with_everything
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      #conn = get(conn, Routes.parking_place_path(conn, :create))
      conn = get conn, "/search/data"
      #IO.puts html_response(conn, 200)
      assert html_response(conn, 200) =~ "Here are the available parking zones with estimated pricing."

    end

    # test "search with address, without hours and minutes", %{conn: conn} do
    #   conn = post(conn, Routes.parking_place_path(conn, :create), %{parking_place: %{destination_address: "Pikk 76, 50603, Tartu",hours: "2", minutes: "5" }})
    #   # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
    #   conn = get(conn, Routes.parking_place_path(conn, :create))
    #   assert html_response(conn, 200) =~ "Here are the available parking zones."
    # end

    # test "search with address, hours and without minutes", %{conn: conn} do
    #   conn = post(conn, Routes.parking_place_path(conn, :create), parking_place: @valid_attrs_without_minutes)
    #   # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
    #   conn = get(conn, Routes.parking_place_path(conn, :create))
    #   assert html_response(conn, 200) =~ "Here are the available parking zones with estimated pricing."
    # end

    # test "search with address, minutes and without hours", %{conn: conn} do
    #   conn = post(conn, Routes.parking_place_path(conn, :create), parking_place: @valid_attrs_without_hours)
    #   # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
    #   conn = get(conn, Routes.parking_place_path(conn, :create))
    #   assert html_response(conn, 200) =~ "Here are the available parking zones with estimated pricing."
    # end

  end

end
