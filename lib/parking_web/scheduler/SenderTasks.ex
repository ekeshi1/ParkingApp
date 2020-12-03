defmodule Parking.SenderTasks do

  alias Parking.{Bookings.Booking, Bookings,Repo,Places.Parking_place}
  import Ecto.Query

  def sendEmail(booking_id) do
      IO.puts("Running scheduled task with id: "<>booking_id)
  end

  def terminateParking(booking_id) do
    IO.puts("Running Booking Termination task with id: "<> booking_id)

    booking = Bookings.get_booking!(String.to_integer(booking_id))
    parking_place = Repo.get!(Parking_place, booking.parking_place_id)


    #Change booking status because driver didnt extend
    Bookings.update_booking(booking,%{status: "TERMINATED"})
    IO.puts("Running Booking Termination task with id: "<> booking_id)

    #Decrement parking place busy places
    parking_place
    |> Parking_place.changeset(%{busy_places: parking_place.busy_places-1})
    |> Repo.update()

  end

end
