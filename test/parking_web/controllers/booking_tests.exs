defmodule ParkingWeb.BookingControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.Bookings
  alias Parking.Guardian
  alias Parking.Account.User
  alias Parking.Places.Parking_place
  alias Parking.Repo



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
      param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)

      #login
      conn = post conn, "/sessions", %{session: [email: "erkesh@ttu.ee", password: "12345"]}
      on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

    {:ok,conn: conn}
    end

    test "successfull hourly booking updates db",%{conn: conn} do

      booking_param = %{lat: "58.3965215", long: "26.735385", isEndingSpecified: false,payment_type: "H"}
      conn = post conn ,"/bookings", %{"booking" => booking_param}


     locHeader = Enum.at((get_location conn.resp_headers),0)
     bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      assert createdBooking.parking_type=="H"

      parking_place = Repo.get!(Parking_place, createdBooking.parking_place_id)
      assert parking_place.busy_places == 3

    end

    test "successfull rt booking updates db",%{conn: conn} do
      booking_param = %{lat: "58.3965215", long: "26.735385", isEndingSpecified: false,payment_type: "RT"}
      conn = post conn ,"/bookings", %{"booking" => booking_param}
      locHeader = Enum.at((get_location conn.resp_headers),0)
      bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

      createdBooking = Bookings.get_booking!(bookingId)

      assert createdBooking.parking_type=="RT"

      parking_place = Repo.get!(Parking_place, createdBooking.parking_place_id)
      assert parking_place.busy_places == 3
    end

  end

  describe "REQ 3.2 system doesnt allow invalid time" do
      setup %{conn: conn} do
        param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
        set =Parking_place.changeset(%Parking_place{},param)
        place= Repo.insert!(set)

        #login
        conn = post conn, "/sessions", %{session: [email: "erkesh@ttu.ee", password: "12345"]}
        on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

      {:ok,conn: conn}
      end

      test "end time cant be before start time",%{conn: conn} do
        {:ok, datetime} = DateTime.now("Etc/UTC")

        hourNow = datetime.hour
        minuteNow = datetime.minute
        booking_param = %{lat: "58.3965215", long: "26.735385", isEndingSpecified: "true", payment_type: "H", end_time: %{hour: Integer.to_string(hourNow+1), minute: Integer.to_string(minuteNow)}}
        conn = post conn ,"/bookings", %{"booking" => booking_param}
        IO.inspect conn.private.phoenix_flash["erorr"]

        assert conn.private.phoenix_flash["error"]=~"End time cant be later than now!"
        #createdBooking = Bookings.get_booking!(bookingId)
        #IO.inspect(createdBooking)
      end

      test "correct endtime provided",%{conn: conn} do
        {:ok, datetime} = DateTime.now("Etc/UTC")

        hourNow = datetime.hour
        minuteNow = datetime.minute

        booking_param = %{lat: "58.3965215", long: "26.735385", isEndingSpecified: "true", payment_type: "H", end_time: %{hour: Integer.to_string(hourNow+3), minute: Integer.to_string(minuteNow)}}
        conn = post conn ,"/bookings", %{"booking" => booking_param}
        IO.inspect conn.private.phoenix_flash["erorr"]

        locHeader = Enum.at((get_location conn.resp_headers),0)
        bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

        createdBooking = Bookings.get_booking!(bookingId)

        assert createdBooking.parking_type=="H"

        parking_place = Repo.get!(Parking_place, createdBooking.parking_place_id)
        assert parking_place.busy_places == 3
        assert createdBooking.end_time != nil
        #createdBooking = Bookings.get_booking!(bookingId)
        #IO.inspect(createdBooking)
      end
    end


    describe "Req 3.3  user cant book when a parking place doesnt have free spaces" do
      setup %{conn: conn} do
        param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 30, zone_id: "A", lat: 58.3965215, long: 26.735385}
        set =Parking_place.changeset(%Parking_place{},param)
        place= Repo.insert!(set)

        #login
        conn = post conn, "/sessions", %{session: [email: "erkesh@ttu.ee", password: "12345"]}
        on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

      {:ok,conn: conn}
      end

      test "user cant book when a parking place doesnt have free spaces", %{conn: conn} do

        booking_param = %{lat: "58.3965215", long: "26.735385", isEndingSpecified: "false", payment_type: "H"}
        conn = post conn ,"/bookings", %{"booking" => booking_param}
        IO.inspect conn.private.phoenix_flash["erorr"]

        assert conn.private.phoenix_flash["error"]=~"Oops,this parking place doesnt have any available space right now. Please find another one."


      end

    end


    describe "User cant book when he has another active parking" do
      setup %{conn: conn} do
        param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 29, zone_id: "A", lat: 58.3965215, long: 26.735385}
        set =Parking_place.changeset(%Parking_place{},param)
        place= Repo.insert!(set)

        #login
        conn = post conn, "/sessions", %{session: [email: "erkesh@ttu.ee", password: "12345"]}
        on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

      {:ok,conn: conn, parking_place: place.id}
      end

      test "User has one Active Parking. He cant make another booking.",%{conn: conn,parking_place: parking_id} do
        user_id = Parking.Authentication.load_current_user(conn).id
        params = %{end_time: "2010-04-17T14:00:00Z", start_time: "2010-04-17T14:00:00Z", status: "ACTIVE", total_amount: 120.5, parking_type: "RT", parking_place_id: parking_id, user_id: user_id}
        {:ok, existingBooking} = Bookings.create_booking(params)

        new_booking_param = %{lat: "58.3965215", long: "26.735385", isEndingSpecified: "false", payment_type: "H"}
        conn = post conn ,"/bookings", %{"booking" => new_booking_param}


        assert conn.private.phoenix_flash["error"]=~"You already have an Active parking!"


      end

    end

    describe "correct automatic parking place location based on user geolocation" do
      setup %{conn: conn} do
        param = %{name: "Raatuse", address: "Raatuse 22", total_places: 30, busy_places: 27, zone_id: "A", lat: 58.382580, long: 26.732060}
        set = Parking_place.changeset(%Parking_place{},param)
        moreFarParkingPlace= Repo.insert!(set)

        param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 29, zone_id: "A", lat: 58.3965215, long: 26.735385}
        set =Parking_place.changeset(%Parking_place{},param)
        closestParkingPlace= Repo.insert!(set)



        #login
        conn = post conn, "/sessions", %{session: [email: "erkesh@ttu.ee", password: "12345"]}
        on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

      {:ok,conn: conn, parking_place: closestParkingPlace}

    end


      test "having two nearby parking_places chooses the closest", %{conn: conn, parking_place: closestParkingPlace} do
        booking_param = %{lat: "58.3965214", long: "26.735385", isEndingSpecified: "false", payment_type: "H"}
        conn = post conn ,"/bookings", %{"booking" => booking_param}
        IO.inspect conn.private.phoenix_flash["erorr"]

        locHeader = Enum.at((get_location conn.resp_headers),0)
        bookingId = String.split(elem(locHeader,1),"/bookings/")
                 |> Enum.at(1)
                 |> String.to_integer

        createdBooking = Bookings.get_booking!(bookingId)
        parking_place = Repo.get!(Parking_place, createdBooking.parking_place_id)
        assert parking_place.id == closestParkingPlace.id
      end

      test "dont allow booking in when available parking places are too far from user location", %{conn: conn} do
        #user location simulated to be Ringtee 75
        booking_param = %{lat: "58.358158", long: "26.680401", isEndingSpecified: "false", payment_type: "H"}
        conn = post conn ,"/bookings", %{"booking" => booking_param}
        assert conn.private.phoenix_flash["error"]=~"We couldn't find a parking place near you!"
      end



    end




  def get_location(res_headers) do
    res_headers
    |> Enum.filter fn tuple -> elem(tuple,0)=="location"

    end
  end




end
