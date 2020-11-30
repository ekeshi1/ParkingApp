defmodule ParkingWeb.BookingController do
  use ParkingWeb, :controller
  alias Parking.Bookings
  alias Parking.Bookings.Booking
  alias Parking.Geolocation
  alias Parking.Repo
  alias Parking.Places.Parking_place
  alias Parking.Places.Zone
  alias Parking.Authentication
  alias Parking.Scheduler
  import Ecto.Query, warn: false
  import Crontab.CronExpression

  def index(conn, _params) do
    bookings = Bookings.list_bookings()
    render(conn, "index.html", bookings: bookings)
    Scheduler.new_job()
    |> Quantum.Job.set_name(:ticker)
    |> Quantum.Job.set_schedule(~e[* * * * *])
    |> Quantum.Job.set_task(fn -> IO.puts("OPAAAA")
                                  :ok end)
    |> Scheduler.add_job()
  end

  def new(conn, _params) do
    changeset = Bookings.change_booking(%Booking{})
    render(conn, "new.html", changeset: changeset,message: "test")
  end

  def create(conn, %{"booking" => booking_params}) do
    IO.inspect(booking_params)
    lat = String.to_float(booking_params["lat"])
    long = String.to_float(booking_params["long"])
    isEndingSpecified = booking_params["isEndingSpecified"]=="true"
    #test = "Raatuse 22,51009,Estonia"
    #IO.puts(test)
    #IO.inspect Geolocation.manual_distance(String.to_float(lat),String.to_float(long),test)


    #IO.puts(lat)
    #IO.puts(long)
    #IO.puts(isEndingSpecified)

    case check_location_near_parking(lat,long) do
      {:ok,closestParkingPlace} ->
        #Check if there are available places first
       if (closestParkingPlace.total_places-closestParkingPlace.busy_places)==0
        do
          #return here.
          conn
          |> put_flash(:eror, "Oops,this parking place doesnt have any available space right now. Please find another one.")
          |> redirect(to: Routes.parking_place(conn, :new))

        else
        #There are places
        user = Authentication.load_current_user(conn)

        IO.puts "OK"
        IO.puts "Found the parking_place"
        IO.inspect(closestParkingPlace)
        bookingMap = %{}
        bookingMap=Map.put(bookingMap,:parking_place, closestParkingPlace.id)
        bookingMap=Map.put(bookingMap,:status,"ACTIVE")
        bookingMap=Map.put(bookingMap,:start_time,DateTime.utc_now())
        endtime = if isEndingSpecified == true do get_utc_date_time(bookingMap.start_time,booking_params["end_time"]) else nil end
        bookingMap=Map.put(bookingMap,:end_time, endtime )
        bookingMap=Map.put(bookingMap, :parking_type, booking_params["payment_type"])

        amount = if isEndingSpecified == true do calculate_amount(bookingMap.start_time, bookingMap.end_time,bookingMap.parking_type,closestParkingPlace) else 0.0 end
        bookingMap=Map.put(bookingMap,:total_amount,amount)
        bookingMap=Map.put(bookingMap,:total_amount,amount)
        bookingMap=Map.put(bookingMap,:user_id ,user.id)
        #IO.inspect bookingMap
        #IO.puts "1"

        #IO.inspect(bookingMap)
        #insert Booking
        uf = Booking.changeset(%Booking{},bookingMap)
            |>Ecto.Changeset.put_assoc(:user,user)
            |>Ecto.Changeset.put_assoc(:parking_place,closestParkingPlace)

        #Update parking place availability


            #  IO.inspect(uf)
        ##booking_struct = Ecto.build_assoc(user, :bookings, Enum.map(bookingMap, fn({key, value}) -> {String.to_atom(key), value} end))
        #IO.inspect booking_struct
        case Repo.insert(uf) do
        {:ok, booking} ->
            updated =
              closestParkingPlace
            |> Parking_place.changeset(%{busy_places: closestParkingPlace.busy_places+1})
            |>Repo.update()
            IO.inspect updated
            schedule_stuff()

            conn
            |> put_flash(:info, "Booking created successfully.")
            |> redirect(to: Routes.booking_path(conn, :show, booking))

          {:error, %Ecto.Changeset{} = changeset} ->
            IO.inspect changeset
            render(conn, "new.html", changeset: changeset)


      :not_ok ->
        conn
        |> put_flash(:eror, "We couldn't find a parking place near you!")
        |> render("new.html", changeset: Bookings.change_booking(%Booking{}))

      end
      end
    end



  end

  @spec schedule_stuff :: :ok
  def schedule_stuff() do
    IO.puts("Scheduling")
  end


  def calculate_amount(start_time, end_time, payment_type,parking_place) do

      IO.puts "################################"
      IO.inspect start_time
      endDatetime=end_time
      IO.inspect DateTime.to_unix(endDatetime)
      IO.inspect DateTime.to_unix(start_time)
      diffMinutes = div(round(DateTime.diff(endDatetime,start_time)),60)
      IO.inspect(diffMinutes)
      hnumber= div(diffMinutes,60)
      hminutes = rem(diffMinutes,60)
      IO.inspect(hnumber)
      IO.inspect(hminutes)
      zone=Enum.at( Repo.all(from t in Zone, where: t.name == ^(parking_place.zone_id), select: t),0)
      hour_price= Float.round(zone.hourly_rate*hnumber , 2)
      realtime_price= Float.round(zone.realtime_rate*hminutes ,2)

      case payment_type do
        "RT"-> IO.puts realtime_price
                realtime_price
        "H" -> IO.puts hour_price
               hour_price
      end
  end

  def get_utc_date_time(start_time,end_time) do
    IO.inspect start_time
    endDatetime = %DateTime{year: start_time.year , month: start_time.month , day: start_time.day, zone_abbr: "EET",
    hour: String.to_integer(end_time["hour"]), minute: String.to_integer(end_time["minute"]), second: 0, microsecond: {0, 0},
     utc_offset: 7200, std_offset: 0, time_zone: "Europe/Tallinn"}
     IO.inspect endDatetime

     endDatetime
    end
  def check_location_near_parking(lat,long) do
    # check if there is a parking place in a distance of
    # less than 0.1 km
  query = from t in Parking_place, select: t

  res =
  Repo.all(query)
  |>Enum.map(fn parking_place ->  Map.put(parking_place,:distance,Geolocation.manual_distance(lat,long,parking_place.address))  end)
  |>Enum.filter(fn parking_place-> parking_place.distance <=1.0 end )
  |>Enum.sort(&(&1.distance< &2.distance))

  #IO.inspect res
  case length(res) == 0 do
    true -> {:not_ok}
    false -> {:ok,Enum.at(res,0)}
  end

  end
  def show(conn, %{"id" => id}) do
    booking = Bookings.get_booking!(id)
    render(conn, "show.html", booking: booking)
  end

  def edit(conn, %{"id" => id}) do
    booking = Bookings.get_booking!(id)
    changeset = Bookings.change_booking(booking)
    render(conn, "edit.html", booking: booking, changeset: changeset)
  end

  def update(conn, %{"id" => id, "booking" => booking_params}) do
    booking = Bookings.get_booking!(id)

    case Bookings.update_booking(booking, booking_params) do
      {:ok, booking} ->
        conn
        |> put_flash(:info, "Booking updated successfully.")
        |> redirect(to: Routes.booking_path(conn, :show, booking))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", booking: booking, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    booking = Bookings.get_booking!(id)
    {:ok, _booking} = Bookings.delete_booking(booking)

    conn
    |> put_flash(:info, "Booking deleted successfully.")
    |> redirect(to: Routes.booking_path(conn, :index))
  end
end
