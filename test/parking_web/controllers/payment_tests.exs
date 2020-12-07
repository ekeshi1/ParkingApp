defmodule ParkingWeb.PaymentTest do
  use ParkingWeb.ConnCase

  alias Parking.Bookings
  alias Parking.Guardian
  alias Parking.Account.User
  alias Parking.Places.Parking_place
  alias Parking.Repo
  alias Parking.Account
  alias Parking.Invoices.Invoice
  import Ecto.Query



  setup_all do
    IO.puts("Set up")
    Ecto.Adapters.SQL.Sandbox.checkout(Parking.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Parking.Repo, {:shared, self()})


    user = Repo.get_by(User, email: "erkesh@ttu.ee")
    conn = build_conn()
    |> bypass_through(Parking.Router, [:browser, :browser_auth, :ensure_auth])
    |> get("/")
    |> Map.update!(:state, fn (_) -> :set end)
    |> Guardian.Plug.sign_in(user)
    |> send_resp(200, "Flush the session")
    |> recycle


    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)



    {:ok, conn: conn}



  end


  describe "REQ 3.1 driver selects horly/real time payment" do

    setup %{conn: conn} do


      param = %{name: "Narva 27", address: "Narva maantee 18", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.390910, long: 26.729980}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)
      {:ok,createdUser} = Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: false})

      #login
      conn = post conn, "/sessions", %{session: [email: createdUser.email, password: createdUser.password]}
      on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

    {:ok,conn: conn}
    end

    test "successfull hourly booking with end time updates user balance and generates invoice",%{conn: conn} do

      dateTime = DateTime.add(DateTime.utc_now(),2*60*60, :second)

      hourNow = dateTime.hour
      minuteNow = dateTime.minute
      booking_param = %{lat: "58.3825317", long: "26.7312859", isEndingSpecified: "true", payment_type: "H", end_time: %{hour: Integer.to_string(hourNow+1), minute: Integer.to_string(minuteNow)}}

      conn = post conn ,"/bookings", %{"booking" => booking_param}
      #IO.inspect conn
     locHeader = Enum.at((get_location conn.resp_headers),0)
     bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      user_id = createdBooking.user_id
      user = Repo.get!(User, user_id)
      invoices = Repo.all(from t in Invoice, where: t.booking_id==^createdBooking.id, select: t)

      invoice = Enum.at(invoices,0)


      #IO.inspect(user)

      assert user.balance == 48.0
      assert length(invoices)==1
      assert invoice.status=="PAID"


    end


    test "successfull hourly booking without end time doesnt generate invoice and doesnt take money from balance",%{conn: conn} do

      booking_param = %{lat: "58.3825317", long: "26.7312859", isEndingSpecified: "false", payment_type: "H"}

      conn = post conn ,"/bookings", %{"booking" => booking_param}
      #IO.inspect conn
     locHeader = Enum.at((get_location conn.resp_headers),0)
     bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      user_id = createdBooking.user_id
      user = Repo.get!(User, user_id)
      invoices = Repo.all(from t in Invoice, where: t.booking_id==^createdBooking.id, select: t)
      assert user.balance == 50.0
      assert length(invoices)==0

    end


  end


  describe "RT Payment when user config is 'Pay Monthly'" do
    setup %{conn: conn} do


      param = %{name: "Narva 27", address: "Narva maantee 18", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.390910, long: 26.729980}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)
      {:ok,createdUser} = Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: true})

      #login
      conn = post conn, "/sessions", %{session: [email: createdUser.email, password: createdUser.password]}
      on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

    {:ok,conn: conn}
    end

    test "booking when end time is specified creates unpaid invoice and doesnt debit", %{conn: conn} do

      dateTime=DateTime.add(DateTime.utc_now(),2*60*60, :second)

      hourNow = dateTime.hour
      minuteNow = dateTime.minute
      booking_param = %{lat: "58.3825317", long: "26.7312859", isEndingSpecified: "true", payment_type: "RT", end_time: %{hour: Integer.to_string(hourNow+1), minute: Integer.to_string(minuteNow)}}

      conn = post conn ,"/bookings", %{"booking" => booking_param}
      #IO.inspect conn
     locHeader = Enum.at((get_location conn.resp_headers),0)
     bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      user_id = createdBooking.user_id
      user = Repo.get!(User, user_id)
      invoices = Repo.all(from t in Invoice, where: t.booking_id==^createdBooking.id, select: t)

      invoice = Enum.at(invoices,0)


      #IO.inspect(user)

      assert user.balance == 50.0
      assert length(invoices) == 1
      assert invoice.status=="UNPAID"
    end

    test "booking when end time is not specified doesnt generate invoice", %{conn: conn} do

      booking_param = %{lat: "58.3825317", long: "26.7312859", isEndingSpecified: "false", payment_type: "RT"}

      conn = post conn ,"/bookings", %{"booking" => booking_param}
      #IO.inspect conn
     locHeader = Enum.at((get_location conn.resp_headers),0)
     bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      user_id = createdBooking.user_id
      user = Repo.get!(User, user_id)
      invoices = Repo.all(from t in Invoice, where: t.booking_id==^createdBooking.id, select: t)
      assert user.balance == 50.0
      assert length(invoices)==0

    end


  end





  describe "RT Payment when user config is 'Each Parking'" do
    setup %{conn: conn} do


      param = %{name: "Narva 27", address: "Narva maantee 18", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.390910, long: 26.729980}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)
      {:ok,createdUser} = Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: false})

      #login
      conn = post conn, "/sessions", %{session: [email: createdUser.email, password: createdUser.password]}
      on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

    {:ok,conn: conn}
    end

    test "booking when end time is specified creates paid invoice and  debits user", %{conn: conn} do

      dateTime=DateTime.add(DateTime.utc_now(),2*60*60, :second)

      hourNow = dateTime.hour
      minuteNow = dateTime.minute
      booking_param = %{lat: "58.3825317", long: "26.7312859", isEndingSpecified: "true", payment_type: "RT", end_time: %{hour: Integer.to_string(hourNow+1), minute: Integer.to_string(minuteNow)}}

      conn = post conn ,"/bookings", %{"booking" => booking_param}
      #IO.inspect conn
     locHeader = Enum.at((get_location conn.resp_headers),0)
     bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      user_id = createdBooking.user_id
      user = Repo.get!(User, user_id)
      invoices = Repo.all(from t in Invoice, where: t.booking_id==^createdBooking.id, select: t)

      invoice = Enum.at(invoices,0)


      #IO.inspect(user)

      assert user.balance == 48.08 #50 -(0.16*12)
      assert length(invoices) == 1
      assert invoice.status=="PAID"
    end

    test "booking when end time is not specified doesnt generate invoice", %{conn: conn} do

      booking_param = %{lat: "58.3825317", long: "26.7312859", isEndingSpecified: "false", payment_type: "RT"}

      conn = post conn ,"/bookings", %{"booking" => booking_param}
      #IO.inspect conn
     locHeader = Enum.at((get_location conn.resp_headers),0)
     bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      user_id = createdBooking.user_id
      user = Repo.get!(User, user_id)
      invoices = Repo.all(from t in Invoice, where: t.booking_id==^createdBooking.id, select: t)
      assert user.balance == 50.0
      assert length(invoices)==0

    end


  end


  def get_location(res_headers) do
    res_headers
    |> Enum.filter fn tuple -> elem(tuple,0)=="location"

    end
  end




end
