defmodule ParkingWeb.SessionController do
  use ParkingWeb, :controller
  alias Parking.{Authentication, Repo}
  alias Parking.Account.User

  def new(conn, _params) do
    render conn, "new.html"
  end

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
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
