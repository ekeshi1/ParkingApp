defmodule WhiteBread.Contexts.ParkingBookingContext do
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
    #Hound.end_session
  end

  given_ ~r/that I am logged in$/, fn state->
    navigate_to "/sessions/new"

    {:ok,createdUser} = Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: false})

    case search_element(:id, "email",2) do
      {:ok,_elem} ->
        fill_field({:id, "email"}, "a@gmail.com")
        fill_field({:id, "password"}, "123")
        click({:id, "login_button"})
        {:ok,state
              |> Map.put("user",createdUser) }

      {:error ,_s}->    {:ok,state}

    end

  end

  and_ ~r/^that the following parking places are available$/, fn state, %{table_data: table} ->
    IO.puts("first")
    table
    |> Enum.map(fn p ->
      Parking_place.changeset(%Parking_place{}, p) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}

  end

  and_ ~r/^I navigate to new bookings page$/, fn state ->
    navigate_to "/bookings/new"
    {:ok, state}

  end

  and_ ~r/^my location is "(?<location>[^"]+)" with latitude "(?<lat>[^"]+)" and longitude "(?<long>[^"]+)"$/,
  fn state, %{location: location, lat: lat, long: long} ->

    IO.inspect lat
    IO.inspect long
    execute_script("document.getElementById('user_lat').value=arguments[0];
    document.getElementById('user_long').value=arguments[1];
    ", [String.to_float(lat), String.to_float(long)])

    #fill_field({:id, "user_lat"},lat)
    #fill_field({:id, "user_long"},long)

    IO.puts("completed location")
    {:ok, state}
  end

  and_ ~r/^I specify ending time 1 hour from now$/, fn state ->
    click({:id,"leaving_time"})

    #get time now
    timenow=DateTime.utc_now()
    hourNow = timenow.hour+2
    minuteNow =timenow.minute

    find_element(:css, "#booking_end_time_hour option[value='"<>Integer.to_string(hourNow+1)<>"']") |> click()
    find_element(:css, "#booking_end_time_minute option[value='"<>Integer.to_string(minuteNow)<>"']") |> click()


    {:ok, state}
  end

  when_ ~r/^I click Book$/, fn state ->
    execute_script("document.getElementById('submit_button').disabled=arguments[0]",[false])
    click({:id, "submit_button"})
    IO.puts("Submited")
    {:ok, state}
  end

  then_ ~r/^I must see an error message "(?<argument_one>[^"]+)"$/,fn state, %{argument_one: _argument_one} ->
    assert visible_in_page? ~r/We couldn't find a parking place near you!/
    {:ok, state}
  end

  and_ ~r/^I choose "(?<argument_one>[^"]+)" payment method$/,
  fn state, %{argument_one: argument_one} ->
    case argument_one do
      "Hourly" -> find_element(:css, "#booking_payment_type option[value='H']") |> click()
      "Real-Time" -> find_element(:css, "#booking_payment_type option[value='RT']") |> click()
    end
    IO.puts("Selected Hourly method")
    {:ok, state}
  end

  then_ ~r/I must see "Booking created successfully.You can now park in 'Narva maante 18'"$/, fn state ->
    IO.puts "Response check"
    assert visible_in_page? ~r/Booking created successfully./
    {:ok,state}
  end

  then_ ~r/I must see "Oops,this parking place doesnt have any available space right now. Please find another one."$/, fn state ->
    IO.puts "Response check"
    assert visible_in_page? ~r/Oops,this parking place doesnt have any available space right now. Please find another one./
    {:ok,state}
  end

  then_ ~r/I must see "Booking is successfull. You can now terminate your parking in 'Narva maantee 18' anytime by clicking Terminate Parking in your bookings."$/, fn state ->
    IO.puts "Response check"
    assert visible_in_page? ~r/Booking is successfull. You can now terminate your parking in 'Narva maantee 18' anytime by clicking Terminate Parking in your bookings./
    {:ok,state}
  end

  and_ ~r/^Total amount must be "(?<argument_one>[^"]+)"$/,
    fn state, %{argument_one: _argument_one} ->
      assert inner_text({:id,"booking_total_amount"})=="-"
      {:ok, state}
    end
  and_ ~r/^Total amount must be calculated$/, fn state ->
    assert inner_text({:id,"booking_total_amount"}) != "-"

    {:ok, state}
  end

  and_ ~r/^End time should not be specified$/, fn state ->
    assert inner_text({:id,"booking_end_time"})==""
    {:ok, state}
  end

  and_ ~r/^End time should be specified$/, fn state ->
    assert inner_text({:id,"booking_end_time"}) != ""
    {:ok, state}
  end


 ##Added for payment

  and_ ~r/^I have "(?<argument_one>[^"]+)" euros in my account$/,
fn state, %{argument_one: account_balance} ->
  IO.puts "Check balance"
  IO.inspect state["user"]
  new_user = state["user"]
            |>User.changeset(%{balance: account_balance})
            |>Repo.update()
  IO.inspect new_user
  {:ok, state}
end


and_ ~r/^I navigate to invoices$/, fn state ->
  "Navigated"
  navigate_to "/invoices"

  {:ok, state}
end
and_ ~r/^I must see an invoice with status "(?<argument_one>[^"]+)" in the screen$/,
fn state, %{argument_one: invoiceStatus} ->

  assert visible_in_page? ~r/PAID/
  {:ok, state}
end

and_ ~r/^I shouldn't see an invoice in the screen$/, fn state ->
  assert  visible_in_page? ~r/No Invoices/
  {:ok, state}

end













end
