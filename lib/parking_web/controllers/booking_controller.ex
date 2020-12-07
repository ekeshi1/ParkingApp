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
  alias Parking.SenderTasks
  import Ecto.Query
  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    bookings = Bookings.list_bookings()

    render(conn, "index.html", bookings: bookings)

  end

  def new(conn, _params) do
    changeset = Bookings.change_booking(%Booking{})
    render(conn, "new.html", changeset: changeset,message: "test")
  end

  def create(conn, %{"booking" => booking_params}) do
    IO.inspect("-------------------------------------------------------------------------")
    IO.inspect(booking_params)
    lat = String.to_float(booking_params["lat"])
    long = String.to_float(booking_params["long"])
    isEndingSpecified = booking_params["isEndingSpecified"]=="true"
    start_time = DateTime.utc_now()
    endtime = if isEndingSpecified == true do get_utc_date_time(start_time,booking_params["end_time"]) else nil end
    user = Authentication.load_current_user(conn)

    IO.inspect endtime
    if isEndingSpecified == true and endtime == nil do
      IO.puts "everything nil"
          conn
          |> put_flash(:error, "End time cant be later than now!")
          |> redirect(to: Routes.booking_path(conn, :new))

    else
      query = from b in "bookings",
              where: b.user_id == ^user.id and b.status=="ACTIVE",
              select: count("*")

      count = Repo.all(query)
              |> Enum.at(0)
      IO.inspect count

      case count do
        0 -> case check_location_near_parking(lat,long) do
          {:ok,closestParkingPlace} ->
            #Check if there are available places first
           if (closestParkingPlace.total_places-closestParkingPlace.busy_places)==0
            do
              #return here.
              conn
              |> put_flash(:error, "Oops,this parking place doesnt have any available space right now. Please find another one.")
              |> redirect(to: Routes.parking_place_path(conn, :index))

            else
            #There are places

            IO.puts "OK"
            IO.puts "Found the parking_place"
            IO.inspect(closestParkingPlace)
            bookingMap = %{}
            bookingMap=Map.put(bookingMap,:parking_place, closestParkingPlace.id)
            bookingMap=Map.put(bookingMap,:status,"ACTIVE")
            bookingMap=Map.put(bookingMap,:start_time,start_time)
            bookingMap=Map.put(bookingMap,:end_time, endtime )
            bookingMap=Map.put(bookingMap, :parking_type, booking_params["payment_type"])

            amount = if isEndingSpecified == true do calculate_amount(bookingMap.start_time, bookingMap.end_time,bookingMap.parking_type,closestParkingPlace) else 0.0 end
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
                if (isEndingSpecified and booking.parking_type=="H") do
                schedule_stuff(booking)
                end
                message=
                if isEndingSpecified do
                  "Booking created successfully. You can now park in '"<> closestParkingPlace.address <> "' ."
                else
                  "Booking is successfull. You can now terminate your parking in '"<>closestParkingPlace.address <> "' anytime by clicking Terminate Parking in your bookings."
                end

                conn
                |> put_flash(:info, message)
                |> redirect(to: Routes.booking_path(conn, :show, booking))

              {:error, %Ecto.Changeset{} = changeset} ->
                IO.inspect changeset
                render(conn, "new.html", changeset: changeset)
              end
            end
          {:not_ok} ->
            IO.puts("Not ok. No parking places")
            conn
            |> put_flash(:error, "We couldn't find a parking place near you!")
            |> render("new.html", changeset: Bookings.change_booking(%Booking{}))
          end

          _ -> conn
              |> put_flash(:error, "You already have an Active parking!")
              |> redirect(to: Routes.booking_path(conn, :index))

      end



    end
  end

  def schedule_stuff(booking) do
    bookingId = Integer.to_string(booking.id)
    IO.puts "Scheduling reminder for booking with id: "<>bookingId

    jobNameReminder="REMINDER_"<> bookingId

    cronExpresionReminder = buildCronExpressionReminder(booking.end_time,10)
    cronExpresionTermination = buildCronExpressionReminder(booking.end_time,2)
    jobNameTermination="TERMINATE_" <> bookingId


    Scheduler.new_job()
    |> Quantum.Job.set_name(String.to_atom(jobNameReminder))
    |> Quantum.Job.set_schedule(cronExpresionReminder)
    |> Quantum.Job.set_task(fn -> SenderTasks.sendEmail(bookingId) end)
    |> Scheduler.add_job()


    Scheduler.new_job()
    |> Quantum.Job.set_name(String.to_atom(jobNameTermination))
    |> Quantum.Job.set_schedule(cronExpresionTermination)
    |> Quantum.Job.set_task(fn -> SenderTasks.terminateParking(bookingId)  end)
    |> Scheduler.add_job()


  end

  def buildCronExpressionReminder(end_time1,nrOfMinutes) do
  secondsBefore = -60*nrOfMinutes
  reminder_time = DateTime.add(end_time1,secondsBefore, :second)
  day = reminder_time.day
  hour = reminder_time.hour
  minute = reminder_time.minute
  month = reminder_time.month
  second = reminder_time.second
  year = reminder_time.year

  expr = %Crontab.CronExpression{
    extended: true,
    second: [second],
    minute: [minute],
    hour: [hour],
    day: [day],
    month: [month],
    weekday: [:*],
    year: [year]}
  IO.inspect expr

  expr
end

  def calculate_amount(start_time, end_time, payment_type,parking_place) do

      IO.puts "################################"
      IO.inspect start_time
      endDatetime=end_time
      IO.inspect DateTime.to_unix(endDatetime)
      IO.inspect DateTime.to_unix(start_time)
      diffMinutes = div(round(DateTime.diff(endDatetime,start_time)),60)
      zone=Enum.at( Repo.all(from t in Zone, where: t.name == ^(parking_place.zone_id), select: t),0)
      hh= div(diffMinutes,60)
      mm = rem(diffMinutes,60)
      hnumber= ceil(( hh*60 +mm)/60 )
      hminutes= ceil(( hh*60 + mm )/5 )
      hour_price= Float.round(zone.hourly_rate*hnumber , 2)
      realtime_price= Float.round(zone.realtime_rate*hminutes ,2)

      IO.inspect(hnumber)
      IO.inspect(hminutes)

      case payment_type do
        "RT"->
          IO.puts realtime_price
            realtime_price
        "H" -> IO.puts hour_price
               hour_price
      end
  end

  def get_utc_date_time(start_time,end_time) do
    IO.puts "start"
    IO.inspect start_time

    endDatetime = %DateTime{year: start_time.year , month: start_time.month , day: start_time.day, zone_abbr: "EET",
    hour: String.to_integer(end_time["hour"]), minute: String.to_integer(end_time["minute"]), second: start_time.second, microsecond: {0, 0},
     utc_offset: 7200, std_offset: 0, time_zone: "Europe/Tallinn"}


     IO.puts "END"

     case DateTime.compare(start_time, endDatetime) do
      :lt -> endDatetime
      :gt -> nil
      :eq -> nil
     end


    end


    @spec check_location_near_parking(any, any) :: {:not_ok} | {:ok, any}
  def check_location_near_parking(lat,long) do
    # check if there is a parking place in a distance of
    # less than 0.1 km
  query = from t in Parking_place, select: t

  res =
  Repo.all(query)
  |>Enum.map(fn parking_place ->  Map.put(parking_place,:distance,Geolocation.find_distance(lat,long,parking_place.lat,parking_place.long))  end)
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
    parking_place = Repo.get!(Parking_place, booking.parking_place_id)

    amount = calculate_amount(booking.start_time, DateTime.add(DateTime.utc_now(), 7200, :second), booking.parking_type, parking_place)

    {:ok, _booking} = Bookings.update_booking(booking, %{end_time: DateTime.utc_now(), total_amount: amount, status: "TERMINATED"})

    conn
    |> put_flash(:info, "Parking Terminated. Total Fee is " <> to_string(amount) <> " euro.")
    |> redirect(to: Routes.booking_path(conn, :index))
  end

  @spec extend_page(Plug.Conn.t(), map) :: Plug.Conn.t()
  def extend_page(conn, %{"id"=> id}) do

    render(conn,"extend.html",id: id, changeset: :changeset)

  end

  def extend(conn, %{"changeset" => %{"end_time" => %{"hour" => hour, "minute" => minute}, "id" => id}}) do
    IO.puts(hour)
    IO.puts(minute)
    IO.puts(id)
    input_time = %{"hour" => hour, "minute" => minute}
    booking = Bookings.get_booking!(id)
    booking_start_time = booking.start_time
    booking_end_time = booking.end_time
    IO.inspect(booking_start_time)
    IO.inspect(booking_end_time)
    new_end_time = get_utc_date_time(booking_start_time, input_time)
    IO.inspect(new_end_time)
    time_diff = DateTime.diff(new_end_time, booking_end_time)
    IO.puts("##############")
    IO.inspect(time_diff)
    IO.puts("###########")

    cond do
      time_diff<=0 -> conn |>put_flash(:error, "Please choose time which is not earlier than previous booking's end time.")
        |> redirect(to: Routes.booking_path(conn, :extend_page, %{id: id}))
        IO.puts("ERROR, CHANGE NEWTIME")
      time_diff>0 ->
        parking_place = Repo.get!(Parking_place, booking.parking_place_id)
        new_amount = calculate_amount(booking.start_time, new_end_time, booking.parking_type, parking_place)
        {:ok, _booking} = Bookings.update_booking(booking, %{end_time: new_end_time, total_amount: new_amount})
        conn
        |> put_flash(:info, "Booking time extended!")
        |> redirect(to: Routes.booking_path(conn, :index))
        IO.puts("Extended succesfully!")
    end


    redirect(conn, to: Routes.booking_path(conn, :index))
  end
end
