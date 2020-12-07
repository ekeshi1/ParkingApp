defmodule Parking.MounthyPay do

  alias Parking.{Bookings.Booking, Bookings,Repo,Places.Parking_place ,Account.User,Invoices}
  import Ecto.Query

  def pay_all() do
    query = from t in User, where: t.monthly_payment ==true, select: t
    users=Repo.all(query)
    users |> Enum.each( fn x ->  Invoices.pay_all(x.id) end)

  end








end
