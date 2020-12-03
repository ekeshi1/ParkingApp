defmodule ParkingWeb.PageController do
  use ParkingWeb, :controller

  def index(conn, _params) do

    IO.puts("Came here")
    user = Parking.Authentication.load_current_user(conn)

    if( not is_nil(user)) do
      conn |> redirect(to: Routes.parking_place_path(conn, :index))


    else conn |> redirect(to: Routes.session_path(conn, :new))
  end
  end
end
