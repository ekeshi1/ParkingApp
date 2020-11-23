defmodule ParkingWeb.Parking_placeController do
  use ParkingWeb, :controller
  #import Ecto.Query, only: [from: 2]
  import Ecto.Query
  alias Parking.Repo
  alias Parking.Places.{Zone, Parking_place}
  #alias Ecto.{Changeset, Multi}

  def index(conn, _params) do
    changeset = Parking_place.changeset(%Parking_place{}, %{})
    render conn, "new.html", changeset: changeset
  end


  def new(conn, _params) do
    changeset = Parking_place.changeset(%Parking_place{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"parking_place" => parking_place_params}) do
    query = from t in Parking_place, select: t
    parking_place_params =Enum.map(parking_place_params, fn({key, value}) -> {String.to_atom(key), value} end)
    places=     Repo.all(query)
                |> Enum.filter (fn x -> Parking.Geolocation.distance(parking_place_params[:destination_address], x.address)>0 end )
    [d1, _] =   Parking.Geolocation.distance(parking_place_params[:destination_address], "Narva mnt 18")
    IO.puts ( parking_place_params[:final_time]  )

    #zones=Repo.all(from t in Zone, select: t)
    #IO.puts ( zones)

    places =  places |> Enum.map(fn x ->
       [d1, d2] =Parking.Geolocation.distance(parking_place_params[:destination_address], x.address)
       Map.merge( %{distance: d1, real_ti: 2},x)
    end  )


    places =  places |> Enum.map(fn x ->
      zone=Enum.at( Repo.all(from t in Zone, where: t.name == ^(x.zone_id), select: t),0)
      hnumber= ceil(( String.to_integer(parking_place_params[:hours])*60 + String.to_integer(parking_place_params[:minutes]) )/60 )
      hour_price= Float.round(zone.hourly_rate*hnumber , 2)
      hminutes= ceil(( String.to_integer(parking_place_params[:hours])*60 + String.to_integer(parking_place_params[:minutes]) )/5 )
      realtime_price= Float.round(zone.realtime_rate*hminutes ,2)
      Map.merge( %{hour_price: hour_price, realtime_price: realtime_price},x)
   end  )



    conn
    |> put_flash(:info,"Here are the available parking zones with estimated pricing.")
    |> render( "index.html", places: places )
  end


end
