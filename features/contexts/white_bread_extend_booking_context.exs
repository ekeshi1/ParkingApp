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
    payment_type_elem = find_element(:id, "booking_payment_type")
    enable_end_time_elem = find_element(:id, "leaving_time")
    end_time_minute_elem = find_element(:id, "booking_end_time_minute")
    submit_button = find_element(:id, "submit_button")
    #select hourly payment
    click(enable_end_time_elem)
    #select minute
    click(submit_button)
    {:ok, state}
  end

  and_ ~r/^there are 8 minutes left until my booking time ends$/, fn state ->
    # TODO:somehow check it
    {:ok, state}
  end

  and_ ~r/^the parking place's current availability is 0$/, fn state ->
    # TODO:somehow check it 2
    {:ok, state}
  end

  and_ ~r/^the payment method is Hourly Payment$/, fn state ->
    # TODO:somehow check it 3
    {:ok, state}
  end

  and_ ~r/^I click the extend link received in my email$/, fn state ->
    navigate_to("/bookings")
    {:ok, state}
  end

  and_ ~r/^I click Extend Parking Time$/, fn state ->
    extend_button = find_element(:id, "extend_button")
    click(extend_button)
    {:ok, state}
  end

  and_ ~r/^I choose the new end time$/, fn state ->
    # TODO: select new time
    {:ok, state}
  end

  then_ ~r/^I should see "(?<argument_one>[^"]+)" on the screen.$/,
  fn state, %{argument_one: _argument_one} ->
    #Booking time extended!
    assert visible_in_page? ~r/Booking time extended!/
    {:ok, state}
  end

end
