defmodule ParkingWeb.ParkingPLacesControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.{Repo, Places.Parking_place, Places.Zone}
  alias Parking.Guardian

  @valid_attrs_with_everything %{destination_address: "Pikk 76, 50603, Tartu",hours: "2", minutes: "5" }
  @valid_attrs_without_time %{destination_address: "Pikk 76, 50603, Tartu",hours: "", minutes: ""}
  @valid_attrs_without_minutes%{destination_address: "Pikk 76, 50603, Tartu",hours: "2", minutes: ""}
  @valid_attrs_without_hours%{destination_address: "Pikk 76, 50603, Tartu",hours: "", minutes: "45"}

  setup do
    conn = build_conn()
      |> Guardian.Plug.sign_out() #Only logged in users can make search, so we make Guadian sign in to be able make search

    {:ok, conn: conn}
  end


  describe "search" do

    test "search with address, hours, and minutes", %{conn: conn} do

      conn = post(conn, Routes.parking_place_path(conn, :create), post: @valid_attrs_with_everything)
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      conn = get(conn, Routes.parking_place_path(conn, :create))
      assert html_response(conn, 200) =~ "Here are the available parking zones with estimated pricing."

    end

    test "search with address, without hours and minutes", %{conn: conn} do
      conn = post(conn, Routes.parking_place_path(conn, :create), post: @valid_attrs_without_time)
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      conn = get(conn, Routes.parking_place_path(conn, :create))
      assert html_response(conn, 200) =~ "Here are the available parking zones."
    end

    test "search with address, hours and without minutes", %{conn: conn} do
      conn = post(conn, Routes.parking_place_path(conn, :create), post: @valid_attrs_with_only_hours)
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      conn = get(conn, Routes.parking_place_path(conn, :create))
      assert html_response(conn, 200) =~ "Here are the available parking zones with estimated pricing."
    end

    test "search with address, without hours and minutes", %{conn: conn} do
      conn = post(conn, Routes.parking_place_path(conn, :create), post: @valid_attrs_without_time)
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      conn = get(conn, Routes.parking_place_path(conn, :create))
      assert html_response(conn, 200) =~ "Here are the available parking zones with estimated pricing."
    end

  end

end
