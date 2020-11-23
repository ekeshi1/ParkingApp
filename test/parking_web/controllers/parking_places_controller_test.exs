defmodule ParkingWeb.ParkingPLacesControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.{Repo, Places.Parking_place, Places.Zone}
  alias Parking.Guardian

  @valid_attrs_with_everything %{destination_address: "Pikk 76, 50603, Tartu",hours:"2", minutes:"5" }
  @valid_attrs_without_time %{destination_address: "Pikk 76, 50603, Tartu",hours: "", minutes: ""}

  setup do
    conn = build_conn()
      |> Guardian.Plug.sign_in() #Only logged in users can make search, so we make Guadian sign in to be able make search

    {:ok, conn: conn}
  end


  describe "search" do

    test "search with address, hours, and minutes", %{conn: conn} do

      conn = post(conn, Routes.post_path(conn, :create), post: @valid_attrs_with_everything)
      assert html_response(conn, 200) =~ "Search executed with hour and minutes"

    end


  end

end
