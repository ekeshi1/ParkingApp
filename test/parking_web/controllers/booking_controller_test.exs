defmodule ParkingWeb.BookingControllerTest do
  use ParkingWeb.ConnCase

  alias Parking.Bookings

  @create_attrs %{end_time: "2010-04-17T14:00:00Z", start_time: "2010-04-17T14:00:00Z", status: "ACTIVE", total_amount: 120.5, parking_type: "RT", parking_place_id: 1, user_id: 1}
  @update_attrs %{end_time: "2011-05-18T15:01:01Z", start_time: "2011-05-18T15:01:01Z", status: "some updated status", total_amount: 456.7, parking_type: "RT", parking_place_id: 1, user_id: 1}
  @invalid_attrs %{end_time: nil, start_time: nil, status: nil, total_amount: nil, parking_type: nil}

  def fixture(:booking) do
    {:ok, booking} = Bookings.create_booking(@create_attrs)
    booking
  end

  describe "index" do
    test "lists all bookings", %{conn: conn} do
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

  describe "create booking" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.booking_path(conn, :create), booking: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.booking_path(conn, :show, id)

      conn = get(conn, Routes.booking_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Booking"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.booking_path(conn, :create), booking: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Booking"
    end
  end

  describe "edit booking" do
    setup [:create_booking]

    test "renders form for editing chosen booking", %{conn: conn, booking: booking} do
      conn = get(conn, Routes.booking_path(conn, :edit, booking))
      assert html_response(conn, 200) =~ "Edit Booking"
    end
  end

  describe "update booking" do
    setup [:create_booking]

    test "redirects when data is valid", %{conn: conn, booking: booking} do
      conn = put(conn, Routes.booking_path(conn, :update, booking), booking: @update_attrs)
      assert redirected_to(conn) == Routes.booking_path(conn, :show, booking)

      conn = get(conn, Routes.booking_path(conn, :show, booking))
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, booking: booking} do
      conn = put(conn, Routes.booking_path(conn, :update, booking), booking: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Booking"
    end
  end

  describe "terminate parking" do
    setup [:create_booking]

    test "terminates chosen parking", %{conn: conn, booking: booking} do
      id = booking.id

      conn = delete(conn, Routes.booking_path(conn, :delete, booking))
      assert redirected_to(conn) == Routes.booking_path(conn, :index)

      updated_booking = Bookings.get_booking!(id)
      assert updated_booking.status == "TERMINATED"
    end
  end

  defp create_booking(_) do
    booking = fixture(:booking)
    %{booking: booking}
  end
end
