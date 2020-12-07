defmodule ParkingWeb.InvoiceController do
  use ParkingWeb, :controller

  alias Parking.Invoices

  def index(conn, _params) do
    user = Parking.Authentication.load_current_user(conn)
    invoices = Invoices.list_my_invoices(user.id)
    render(conn, "index.html", invoices: invoices)
  end

end
