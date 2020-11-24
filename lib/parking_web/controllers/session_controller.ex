defmodule ParkingWeb.SessionController do
  use ParkingWeb, :controller
  alias Parking.{Authentication, Repo}
  alias Parking.Account.User

  def new(conn, _params) do
    user = Parking.Authentication.load_current_user(conn)
    if( not is_nil(user)) do
      conn |> redirect(to: Routes.parking_place_path(conn, :index))


    else  render conn, "new.html"
  end
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    user = Repo.get_by(User, email: email)
    case Authentication.check_credentials(user, password) do
      {:ok, _} ->
        conn
        |> Authentication.login(user)
        |> put_flash(:info, "Successfully logged in")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, :unknown_user} ->
        conn
        |> put_flash(:error,"User doesn't exist")
        |> render("new.html")
      {:error, :wrong_password} ->
        conn
        |> put_flash(:error,"Wrong password! Please try again")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Parking.Authentication.logout()
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
