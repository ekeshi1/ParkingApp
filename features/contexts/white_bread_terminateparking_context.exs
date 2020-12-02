defmodule WhiteBread.Contexts.TerminateParkingContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Ecto.Query
  alias Parking.{Repo,Account.User,Account, Bookings, Bookings.Booking, Places.Parking_place}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
    IO.puts "Started"
  end


  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Parking.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Parking.Repo, {:shared, self()})
    %{}
  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo)
    Hound.end_session
  end

  given_ ~r/^that I have booked a real time parking space with no end time$/, fn state ->

    param = %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385}
    set =Parking_place.changeset(%Parking_place{},param)
    place= Repo.insert!(set)

    IO.inspect place
    IO.inspect place.id
    Bookings.create_booking(%{end_time: nil, start_time: DateTime.utc_now(), status: "ACTIVE", total_amount: 0.0,
    user_id: 1, parking_place_id: place.id, parking_type: "RT"})
    {:ok, state}
  end

  and_ ~r/^I go to My Parkings page$/, fn state ->
    navigate_to "/bookings"
    {:ok, state}
  end

  and_ ~r/^I see my ongoing parking booking listed$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I see a button "(?<button_name>[^"]+)"$/, fn state, %{button_name: button_name} ->
    assert visible_in_page? Regex.compile!(button_name)
    {:ok, state |> Map.put(:button_name, button_name)}
  end

  when_ ~r/^I click It $/, fn state ->
    element = find_element(:link_text, state[:button_name])
    click(element)
    {:ok, state}
  end

  then_ ~r/^I should see a "(?<message>[^"]+)" message.$/, fn state, %{message: message} ->
    assert visible_in_page? Regex.compile!(message)
    {:ok, state}
  end

end
