defmodule WhiteBread.Contexts.ExtendBookingContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Ecto.Query
  alias Parking.{Repo,Account.User,Account}

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
    navigate_to("/bookings/new")
    find_element(:css, "#booking_payment_type option[value='H']") |> click()
    find_element(:id, "leaving_time") |> click()
    timenow=DateTime.utc_now()
    hourNow = timenow.hour+2
    minuteNow =timenow.minute

    find_element(:css, "#booking_end_time_hour option[value='"<>Integer.to_string(hourNow)<>"']") |> click()
    find_element(:css, "#booking_end_time_minute option[value='"<>Integer.to_string(minuteNow+7)<>"']") |> click()

    submit_button = find_element(:id, "submit_button")
    click(submit_button)
    {:ok, state}
  end

  and_ ~r/^there are 8 minutes left until my booking time ends$/, fn state ->
    # checked
    {:ok, state}
  end

  and_ ~r/^the payment method is Hourly Payment$/, fn state ->
    # checked
    {:ok, state}
  end

  and_ ~r/^I click the extend link received in my email$/, fn state ->
    #checked
    {:ok, state}
  end

  and_ ~r/^I click Extend Parking Time$/, fn state ->
    find_element(:id, "extend_button") |> click()
    {:ok, state}
  end

  and_ ~r/^I choose the new end time$/, fn state ->
    timenow=DateTime.utc_now()
    hourNow = timenow.hour+2
    minuteNow = timenow.minute+10
    if timenow.minute+10> 60 do
      minuteNow = 60 - timenow.minute+10
      hourNow = hourNow + 1
    end


    find_element(:css, "#booking_end_time_hour option[value='"<>Integer.to_string(hourNow)<>"']") |> click()
    find_element(:css, "#booking_end_time_minute option[value='"<>Integer.to_string(minuteNow)<>"']") |> click()
    find_element(:id,"submit_button")|>click()
    {:ok, state}
  end

  then_ ~r/^I should see "(?<argument_one>[^"]+)" on the screen.$/,
  fn state, %{argument_one: _argument_one} ->
    #Booking time extended!
    assert visible_in_page? ~r/Booking time extended!/
    {:ok, state}
  end

end
