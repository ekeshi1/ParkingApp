defmodule Parking.Authentication do
  alias Parking.Guardian

  def check_credentials(user, password) do
    if user && password do
      if password == user.password do
        {:ok, user}
      else
        {:error, :wrong_password}
      end
    else
      {:error, :unknown_user}
    end
  end

  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
  end

  def logout(conn) do
    conn
    |> Guardian.Plug.sign_out()
  end

  @spec load_current_user(Plug.Conn.t()) :: any
  def load_current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end
end
