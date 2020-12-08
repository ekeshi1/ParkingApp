defmodule ParkingWeb.TerminateParkingTest do
  use ParkingWeb.ConnCase

  import Ecto.Query, warn: false
  alias Parking.Bookings
  alias Parking.Guardian
  alias Parking.Account.User
  alias Parking.Places.Parking_place
  alias Parking.Repo
  alias Parking.Invoices.Invoice
  alias Parking.Account


  setup_all do
    IO.puts("Set up")
    Ecto.Adapters.SQL.Sandbox.checkout(Parking.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Parking.Repo, {:shared, self()})


    conn = build_conn()

    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo) end)

    {:ok, conn: conn}
  end
describe "REQ 4.3 terminate parking when Real Time payment " do


  test "Parking terminated successfully and UNPAID invoice generated when MOnthly Payment configured", %{conn: conn} do
    param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
    set =Parking_place.changeset(%Parking_place{},param)
    place= Repo.insert!(set)
    {:ok,createdUser} = Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: true})
    conn = post conn, "/sessions", %{session: [email: createdUser.email, password: createdUser.password]}
    params = %{end_time: "2010-04-17T14:00:00Z", start_time: "2010-04-17T14:00:00Z", status: "ACTIVE", total_amount: 120.5, parking_type: "RT", parking_place_id: place.id, user_id: createdUser.id}
    {:ok, booking} = Bookings.create_booking(params)
    id=booking.id
    conn = delete(conn, Routes.booking_path(conn, :delete, booking))
    assert redirected_to(conn) == Routes.booking_path(conn, :index)

    user = Repo.get!(User, createdUser.id)
    invoices = Repo.all(from t in Invoice, where: t.booking_id==^booking.id, select: t)

    invoice = Enum.at(invoices,0)
    updated_booking = Bookings.get_booking!(id)
    assert updated_booking.status == "TERMINATED"
    assert invoice.status=="UNPAID"
    assert length(invoices)==1

  end

  test "Parking terminated successfully and PAID invoice generated when Each Parking payment is configured", %{conn: conn} do
    param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
    set =Parking_place.changeset(%Parking_place{},param)
    place= Repo.insert!(set)
    {:ok,createdUser} = Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: false})

    conn = post conn, "/sessions", %{session: [email: createdUser.email, password: createdUser.password]}

    params = %{end_time: "2010-04-17T14:00:00Z", start_time: "2010-04-17T14:00:00Z", status: "ACTIVE", total_amount: 120.5, parking_type: "RT", parking_place_id: place.id, user_id: createdUser.id}
    {:ok, booking} = Bookings.create_booking(params)
    id=booking.id
    conn = delete(conn, Routes.booking_path(conn, :delete, booking))
    assert redirected_to(conn) == Routes.booking_path(conn, :index)

    user = Repo.get!(User, createdUser.id)
    invoices = Repo.all(from t in Invoice, where: t.booking_id==^booking.id, select: t)

    invoice = Enum.at(invoices,0)
    updated_booking = Bookings.get_booking!(id)
    assert updated_booking.status == "TERMINATED"
    assert invoice.status=="PAID"
    assert length(invoices)==1

  end

end

  describe " Hourly payment parking termination" do
    test "Parking terminated successfully and PAID invoice generated when Each Parking payment is configured", %{conn: conn} do
      param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
      set =Parking_place.changeset(%Parking_place{},param)
      place= Repo.insert!(set)
      {:ok,createdUser} = Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: false})
      conn = post conn, "/sessions", %{session: [email: createdUser.email, password: createdUser.password]}
      params = %{end_time: "2010-04-17T14:00:00Z", start_time: "2010-04-17T14:00:00Z", status: "ACTIVE", total_amount: 120.5, parking_type: "H", parking_place_id: place.id, user_id: createdUser.id}
      {:ok, booking} = Bookings.create_booking(params)
      id=booking.id
      conn = delete(conn, Routes.booking_path(conn, :delete, booking))
      assert redirected_to(conn) == Routes.booking_path(conn, :index)

      user = Repo.get!(User, createdUser.id)
      invoices = Repo.all(from t in Invoice, where: t.booking_id==^booking.id, select: t)

      invoice = Enum.at(invoices,0)
      updated_booking = Bookings.get_booking!(id)
      assert updated_booking.status == "TERMINATED"
      assert invoice.status=="PAID"
      assert length(invoices)==1


  end
end
end
