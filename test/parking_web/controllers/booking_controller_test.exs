defmodule ParkingWeb.BookingControllerTest do
  use ParkingWeb.ConnCase

  import Ecto.Query, warn: false
  alias Parking.Bookings
  alias Parking.Guardian
  alias Parking.Account.User
  alias Parking.Places.Parking_place
  alias Parking.Repo
  alias Parking.Invoices.Invoice



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


    #conn = post conn, "/sessions", %{session: [email: "erkesh@ttu.ee", password: "12345"]}


    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

    {:ok, conn: conn}
  end

  @create_attrs %{end_time: "2010-04-17T14:00:00Z", start_time: "2010-04-17T14:00:00Z", status: "ACTIVE", total_amount: 120.5, parking_type: "RT", parking_place_id: 1, user_id: 1}
  @update_attrs %{end_time: "2011-05-18T15:01:01Z", start_time: "2011-05-18T15:01:01Z", status: "some updated status", total_amount: 456.7, parking_type: "RT", parking_place_id: 1, user_id: 1}
  @invalid_attrs %{end_time: nil, start_time: nil, status: nil, total_amount: nil, parking_type: nil}





  def fixture(:booking) do
    {:ok, booking} = Bookings.create_booking(@create_attrs)

    booking
  end

  describe "index" do
    test "lists all bookings", %{conn: conn} do
      conn = post conn, "/sessions", %{session: [email: "bob@gmail.com", password: "123"]}
      conn = get(conn, Routes.booking_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Bookings"
    end
  end

  describe "new booking" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.booking_path(conn, :new))
      assert html_response(conn, 200) =~ "New Booking"
    end
  end

  describe "terminate parking" do


    test "terminates chosen parking", %{conn: conn} do
      param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)

      IO.inspect place
      params = %{end_time: "2010-04-17T14:00:00Z", start_time: "2010-04-17T14:00:00Z", status: "ACTIVE", total_amount: 120.5, parking_type: "RT", parking_place_id: place.id, user_id: 1}
      {:ok, booking} = Bookings.create_booking(params)
      id=booking.id
      conn = delete(conn, Routes.booking_path(conn, :delete, booking))
      assert redirected_to(conn) == Routes.booking_path(conn, :index)

      updated_booking = Bookings.get_booking!(id)
      assert updated_booking.status == "TERMINATED"
    end
  end

  describe "extend parking" do


    test "new end time is not earlier than old one ", %{conn: conn} do
      param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)

      IO.inspect place
      params = %{end_time: "2021-04-17T15:00:00Z", start_time: "2021-04-17T14:00:00Z", status: "ACTIVE", total_amount: 2.5, parking_type: "H", parking_place_id: place.id, user_id: 1}
      {:ok, booking} = Bookings.create_booking(params)

      id=booking.id
      end_time_before = booking.end_time

      conn = get(conn, Routes.booking_path(conn, :extend_page, %{"id"=>id}))
      assert html_response(conn, 200) =~ "Extend Parking"

      new_end_time = DateTime.add(end_time_before,-10*60, :second)
      hour = new_end_time.hour
      minute = new_end_time.minute
      params_for_extend = %{"changeset" => %{"end_time" => %{"hour" => hour, "minute" => minute}, "id" => id}}
      conn = post(conn, Routes.booking_path(conn, :extend, params_for_extend))
      assert html_response(conn,302)
      IO.puts("##############")
      IO.puts("PASSED")
      IO.puts("##############")


    end

    test "verify new end time", %{conn: conn} do
      param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)

      IO.inspect place
      params = %{end_time: "2021-04-17T15:00:00Z", start_time: "2021-04-17T14:00:00Z", status: "ACTIVE", total_amount: 2.5, parking_type: "H", parking_place_id: place.id, user_id: 1}
      {:ok, booking} = Bookings.create_booking(params)

      id=booking.id
      end_time_before = booking.end_time
      IO.inspect(end_time_before)

      conn = get(conn, Routes.booking_path(conn, :extend_page, %{"id"=>id}))
      assert html_response(conn, 200) =~ "Extend Parking"

      new_end_time = DateTime.add(end_time_before,2*60*60+10*60, :second)# adding 2 hours to make time utc+2
      hour = new_end_time.hour
      minute = new_end_time.minute
      IO.inspect(minute)
      params_for_extend = %{"changeset" => %{"end_time" => %{"hour" => Integer.to_string(hour), "minute" => Integer.to_string(minute)}, "id" => id}}
      conn = post(conn, Routes.booking_path(conn, :extend, params_for_extend))
      assert redirected_to(conn) == Routes.booking_path(conn, :index)

      updated_booking = Bookings.get_booking!(id)
      IO.inspect(updated_booking.end_time)
      diff = DateTime.diff(updated_booking.end_time, end_time_before )

      assert diff==600
      IO.puts("##############")
      IO.puts("PASSED")
      IO.puts("##############")
    end

    test "verify new parking fee calculated correctly", %{conn: conn} do
      param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)

      IO.inspect place
      params = %{end_time: "2021-04-17T15:00:00Z", start_time: "2021-04-17T14:00:00Z", status: "ACTIVE", total_amount: 2.5, parking_type: "H", parking_place_id: place.id, user_id: 1}
      {:ok, booking} = Bookings.create_booking(params)

      id=booking.id
      end_time_before = booking.end_time
      total_amount_before = booking.total_amount


      conn = get(conn, Routes.booking_path(conn, :extend_page, %{"id"=>id}))
      assert html_response(conn, 200) =~ "Extend Parking"

      new_end_time = DateTime.add(end_time_before,4*60*60, :second)#adding 2 hour to extend parking and 2 hours to make time utc+2
      hour = new_end_time.hour
      minute = new_end_time.minute
      params_for_extend = %{"changeset" => %{"end_time" => %{"hour" => hour, "minute" => minute}, "id" => id}}
      conn = post(conn, Routes.booking_path(conn, :extend, params_for_extend))
      assert redirected_to(conn) == Routes.booking_path(conn, :index)

      updated_booking = Bookings.get_booking!(id)
      total_amount_after = updated_booking.total_amount

      assert total_amount_after-total_amount_before == 3.5
      IO.puts("##############")
      IO.puts("PASSED")
      IO.puts("##############")

    end

    test "verify invoice gets generated", %{conn: conn} do
      param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)

      params = %{end_time: "2021-04-17T15:00:00Z", start_time: "2021-04-17T14:00:00Z", status: "ACTIVE", total_amount: 2.5, parking_type: "H", parking_place_id: place.id, user_id: 1}
      {:ok, booking} = Bookings.create_booking(params)

      id=booking.id
      end_time_before = booking.end_time
      total_amount_before = booking.total_amount


      conn = get(conn, Routes.booking_path(conn, :extend_page, %{"id"=>id}))
      assert html_response(conn, 200) =~ "Extend Parking"

      new_end_time = DateTime.add(end_time_before,4*60*60, :second)#adding 2 hour to extend parking and 2 hours to make time utc+2
      hour = new_end_time.hour
      minute = new_end_time.minute
      params_for_extend = %{"changeset" => %{"end_time" => %{"hour" => hour, "minute" => minute}, "id" => id}}
      conn = post(conn, Routes.booking_path(conn, :extend, params_for_extend))
      assert redirected_to(conn) == Routes.booking_path(conn, :index)

      query = from invoice in Invoice, select: invoice, where: (invoice.booking_id == ^booking.id) and invoice.status == "PAID"
      invoices = Repo.all(query)

      assert length(invoices) == 1
      IO.puts("##############")
      IO.puts("PASSED")
      IO.puts("##############")

    end

  end





  defp create_booking(_) do
    booking = fixture(:booking)
    %{booking: booking}
  end
end
