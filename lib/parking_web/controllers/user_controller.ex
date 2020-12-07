defmodule ParkingWeb.UserController do
  use ParkingWeb, :controller

  alias Parking.Account
  alias Parking.Account.User

  def index(conn, _params) do

    render(conn, "index.html")
  end

  def new(conn, _params) do
    user = Parking.Authentication.load_current_user(conn)

    if( not is_nil(user)) do
      conn |> redirect(to: Routes.parking_place_path(conn, :index))


    else  changeset = Account.change_user(%User{})

          render(conn, "new.html", changeset: changeset)

  end


  end

  def create(conn, %{"user" => user_params}) do
    IO.puts("Came in controller. Creating")
    case Account.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Successfully registered!")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Account.get_user!(id)

    if user.monthly_payment do
      # TODO pay for all the unpaid invoices
      Account.update_user(user, %{monthly_payment: false})
    else
      Account.update_user(user, %{monthly_payment: true})
    end

    redirect(conn, to: Routes.user_path(conn, :index))
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Account.get_user!(id)

    case Account.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    {:ok, _user} = Account.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
