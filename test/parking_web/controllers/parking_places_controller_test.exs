defmodule ParkingWeb.ParkingPLacesControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.{Repo, Places.Parking_place, Places.Zone}
  alias Parking.Guardian

  setup do
    conn = build_conn()
      |> Guardian.Plug.sign_in() #Only logged in users can make search, so we make Guadian sign in to be able make search

    {:ok, conn: conn}
  end


  describe "search" do

    # test "search with address, hours, and minutes", %{conn: conn} do

    #   conn = post conn, "search/some", %{}
    # end
  end

end
