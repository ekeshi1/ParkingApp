defmodule ParkingWeb.InvoiceController do
  use ParkingWeb, :controller

  alias Parking.Invoices
  alias Parking.Invoices.Invoice

  def index(conn, _params) do

    invoices = Invoices.list_invoices()
    render(conn, "index.html", invoices: invoices)
  end

end
