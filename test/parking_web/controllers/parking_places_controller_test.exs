defmodule ParkingWeb.ParkingPLacesControllerTest do
  use ParkingWeb.ConnCase
  import Ecto.Query
  alias Parking.Repo
  alias Parking.{Repo, Places.Parking_place, Places.Zone,Places.Parametre}
  alias Parking.Guardian

  @valid_attrs_with_everything %{destination_address: "Pikk 76, 50603, Tartu",hours: "2", minutes: "5" }
  @valid_attrs_without_time %{destination_address: "Pikk 76, 50603, Tartu",hours: "", minutes: ""}
  @valid_attrs_without_minutes%{destination_address: "Pikk 76, 50603, Tartu",hours: "6", minutes: ""}
  @valid_attrs_without_hours%{destination_address: "Pikk 76, 50603, Tartu",hours: "", minutes: "1"}




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
      assert html_response(conn, 200) =~ "Here are the available parking zones."

    end

    test "search with address, without hours and minutes", %{conn: conn} do
      conn = post conn, "/search/some", parking_place: @valid_attrs_without_time
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      #conn = get(conn, Routes.parking_place_path(conn, :create))
      conn = get conn, "/search/data"
      assert html_response(conn, 200) =~ "Here are the available parking zones."
    end

    test "search with address, hours and without minutes", %{conn: conn} do
      conn = post conn, "/search/some", parking_place: @valid_attrs_without_minutes
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      #conn = get(conn, Routes.parking_place_path(conn, :create))
      conn = get conn, "/search/data"
      assert html_response(conn, 200) =~ "Here are the available parking zones."
    end

    test "search with address, minutes and without hours", %{conn: conn} do
      conn = post conn, "/search/some", parking_place: @valid_attrs_without_hours
      # assert redirected_to(conn) == Routes.parking_place_path(conn, :create)
      #conn = get(conn, Routes.parking_place_path(conn, :create))
      conn = get conn, "/search/data"
      assert html_response(conn, 200) =~ "Here are the available parking zones."
    end



    test "test distances are in radius and only available places shown", %{conn: conn} do
      # [
      #   %{name: "Delta", address: "Narva maantee 18", total_places: 30, busy_places: 2, zone_id: "A" , lat: 58.390910, long: 26.729980},
      #   %{name: "Lounakeskus", address: "Ringtee 75", total_places: 45, busy_places: 22, zone_id: "A", lat: 58.358158, long: 26.680401},
      #   %{name: "Eeden", address: "Kalda tee 1c", total_places: 35, busy_places: 13, zone_id: "B", lat: 58.372800, long: 26.753930},
      #   %{name: "Raatuse", address: "Raatuse 22", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.382580, long: 26.732060},
      #   %{name: "Lounakeskus 2", address: "Ringtee 74", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3586092, long: 26.6765849},
      #   %{name: "Pikk", address: "Pikk 40", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.382213, long: 26.7355454},
      #   %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385},
      #   ]
      #  |> Enum.map(fn parking_place_data -> Parking_place.changeset(%Parking_place{}, parking_place_data) end)
      #  |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

      conn = post conn, "/search/some", parking_place: @valid_attrs_without_time
      places = Repo.all(Parametre)
      places
      |> Enum.each(fn p -> assert p.distance < 5.0 end)
      places
      |> Enum.each(fn p -> assert (p.total_places > p.busy_places) end)
      IO.inspect places
      conn = get conn, "/search/data"
      assert html_response(conn, 200) =~ "Here are the available parking zones."
    end


    test "test that Verify the availability for retrieved spots is always >= 1, and the price corresponds to the parking spot zone (A or B)", %{conn: conn} do
      conn = post conn, "/search/some", parking_place: @valid_attrs_without_time

      zoneA=Enum.at( Repo.all(from t in Zone, where: t.name == "A", select: t),0)
      zoneB=Enum.at( Repo.all(from t in Zone, where: t.name == "B", select: t),0)

      places = Repo.all(Parametre)
      places
      |> Enum.each(fn p -> if p.zone_id=="A" do assert (p.hour_rate==zoneA.hourly_rate and p.realtime_rate==zoneA.realtime_rate) else assert (p.hour_rate==zoneB.hourly_rate and p.realtime_rate==zoneB.realtime_rate) end   end)
      places
      |> Enum.each(fn p -> assert (p.total_places > p.busy_places) end)
      IO.inspect places
      conn = get conn, "/search/data"
      assert html_response(conn, 200) =~ "Here are the available parking zones."
    end



    test "Verify if the fee calculated is correct for a given distance under hourly payment restrictions", %{conn: conn} do

      conn = post conn, "/search/some", parking_place: @valid_attrs_with_everything
      hh=@valid_attrs_with_everything.hours
      mm=@valid_attrs_with_everything.minutes
      places = Repo.all(Parametre)
      places |> Enum.each(fn x ->
        zone=Enum.at( Repo.all(from t in Zone, where: t.name == ^(x.zone_id), select: t),0)
        hnumber= ceil(( String.to_integer(hh)*60 + String.to_integer(mm) )/60 )
        hour_price= Float.round(zone.hourly_rate*hnumber , 2)
        hminutes= ceil(( String.to_integer(hh)*60 + String.to_integer(mm) )/5 )
        realtime_price= Float.round(zone.realtime_rate*hminutes ,2)
        assert x.hour_price==hour_price
        assert x.realtime_price==realtime_price
        end  )
      conn = get conn, "/search/data"
      assert html_response(conn, 200) =~ "Here are the available parking zones."
    end





  end

end
