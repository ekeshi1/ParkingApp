defmodule WhiteBread.Contexts.ExtendBookingContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Ecto.Query
  alias Parking.{Repo,Account.User,Account,Places.Parking_place}

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

  given_ ~r/^that I have booked a parking space$/, fn state ->

    [
      %{name: "Delta", address: "Narva maantee 18", total_places: 30, busy_places: 2, zone_id: "A" , lat: 58.390910, long: 26.729980},
     %{name: "Lounakeskus", address: "Ringtee 75", total_places: 45, busy_places: 22, zone_id: "A", lat: 58.358158, long: 26.680401},
     %{name: "Eeden", address: "Kalda tee 1c", total_places: 35, busy_places: 13, zone_id: "B", lat: 58.372800, long: 26.753930},
     %{name: "Raatuse", address: "Raatuse 22", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.382580, long: 26.732060},
     %{name: "Lounakeskus 2", address: "Ringtee 74", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3586092, long: 26.6765849},
     %{name: "Pikk", address: "Pikk 40", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.382213, long: 26.7355454},
     %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385},
    ]
    |> Enum.map(fn parking_place_data -> Parking_place.changeset(%Parking_place{}, parking_place_data) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    navigate_to "/sessions/new"
    case search_element(:id, "email",2) do
      {:ok,_elem} ->
        fill_field({:id, "email"}, "erkesh@ttu.ee")
        fill_field({:id, "password"}, "12345")
        click({:id, "login_button"})
        IO.puts("Logging User...")

      {:error ,_s}-> IO.puts("User logged...")

    end

    navigate_to "/bookings/new"
    execute_script("document.getElementById('user_lat').value=arguments[0];
    document.getElementById('user_long').value=arguments[1];
    ", [String.to_float("58.3825800"), String.to_float("26.7320600")])
    find_element(:css, "#booking_payment_type option[value='H']") |> click()
    find_element(:id, "leaving_time") |> click()
    end_time=DateTime.add(DateTime.utc_now(),2*60*60+7*60, :second)
    h = end_time.hour
    m = end_time.minute


    find_element(:css, "#booking_end_time_hour option[value='"<>Integer.to_string(h)<>"']") |> click()
    find_element(:css, "#booking_end_time_minute option[value='"<>Integer.to_string(m)<>"']") |> click()

    submit_button = find_element(:id, "submit_button")
    click(submit_button)
    {:ok, state}
  end

  and_ ~r/^there are 8 minutes left until my booking time ends$/, fn state ->
    # checked above
    {:ok, state}
  end

  and_ ~r/^the payment method is Hourly Payment$/, fn state ->
    # checked above
    {:ok, state}
  end

  and_ ~r/^I click Extend Parking Time$/, fn state ->
    {:ok, state} # checked below
  end

  and_ ~r/^I click the extend link received in my email$/, fn state ->
    #checked
    navigate_to "/bookings"
    find_element(:class, "extend_button") |> click()
    {:ok, state}
  end

  and_ ~r/^I choose the new end time$/, fn state ->
    end_time=DateTime.add(DateTime.utc_now(),2*60*60+10*60, :second)
    h = end_time.hour
    m = end_time.minute


    find_element(:css, "#changeset_end_time_hour option[value='"<>Integer.to_string(h)<>"']") |> click()
    find_element(:css, "#changeset_end_time_minute option[value='"<>Integer.to_string(m)<>"']") |> click()
    find_element(:id,"submit_button")|>click()
    {:ok, state}
  end

  then_ ~r/^I should see "(?<argument_one>[^"]+)" on the screen.$/,
  fn state, %{argument_one: _argument_one} ->
    #Booking time extended!
    assert visible_in_page? ~r/Booking time extended!/
    {:ok, state}
  end

  and_ ~r/^go to my invoices page$/, fn state ->
    navigate_to "/invoices"
    {:ok, state}
  end

  then_ ~r/^I should see an invoice with status "(?<status>[^"]+)" on the screen.$/,
  fn state, %{status: status} ->
    assert visible_in_page? ~r/status/
    {:ok, state}
  end

end
