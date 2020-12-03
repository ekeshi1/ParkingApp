defmodule ParkingWeb.Parking_placeController do
  use ParkingWeb, :controller
  #import Ecto.Query, only: [from: 2]
  import Ecto.Query
  alias Parking.Repo
  alias Parking.Places.{Zone, Parking_place,Parametre}
  alias Ecto.{Changeset, Multi}

  def index(conn, _params) do
    changeset = Parking_place.changeset(%Parking_place{}, %{})
    render conn, "new.html", changeset: changeset
  end


  def new(conn, _params) do
    places = Repo.all(Parametre)
    Repo.delete_all(Parametre)
    render conn, "index.html", places: places
  end

  def create(conn, %{"parking_place" => parking_place_params}) do
    query = from t in Parking_place, select: t
    parking_place_params =Enum.map(parking_place_params, fn({key, value}) -> {String.to_atom(key), value} end)
    [dlat,dlong]=Parking.Geolocation.find_location(parking_place_params[:destination_address])
    places=     Repo.all(query)
                |> Enum.filter (fn x -> Parking.Geolocation.find_distance(x.lat,x.long, dlat,dlong)<5.0 end )
    #[d1, _] =   Parking.Geolocation.distance(parking_place_params[:destination_address], "Narva mnt 18")
    #IO.puts ( parking_place_params[:final_time]  )

    #zones=Repo.all(from t in Zone, select: t)
    #IO.puts ( zones)



    places =  places |> Enum.map(fn x ->
       dist=Parking.Geolocation.find_distance(x.lat,x.long, dlat,dlong)
       Map.merge( %{distance: dist, real_ti: 2},x)
    end  )


    hh = if parking_place_params[:hours] == ""  do  "0" else  parking_place_params[:hours] end

    mm = if parking_place_params[:minutes] == ""  do  "0" else  parking_place_params[:minutes] end



    places =  places |> Enum.map(fn x ->
      zone=Enum.at( Repo.all(from t in Zone, where: t.name == ^(x.zone_id), select: t),0)
      hnumber= ceil(( String.to_integer(hh)*60 + String.to_integer(mm) )/60 )
      hour_price= Float.round(zone.hourly_rate*hnumber , 2)
      hminutes= ceil(( String.to_integer(hh)*60 + String.to_integer(mm) )/5 )
      realtime_price= Float.round(zone.realtime_rate*hminutes ,2)
      Map.merge( %{hour_price: hour_price, realtime_price: realtime_price},x)
   end  ) |> Enum.sort(&(&1.distance< &2.distance))

    Enum.each(places, fn(place) ->          changeset=Parametre.changeset(%Parametre{}, %{address: place.address, busy_places: place.busy_places , total_places: place.total_places, distance: place.distance, hour_price: place.hour_price, name: place.name, realtime_price: place.realtime_price, zone_id: place.zone_id})
                                            Repo.insert(changeset)
                                            #IO.puts changeset
                                            end)
    # changeset=Parametre.changeset(%Parametre{}, places)
    # Repo.insert(changeset)

    conn
    |> put_flash(:info,"Here are the available parking zones.")
    |> redirect(to: Routes.parking_place_path(conn, :new))

  end


end
