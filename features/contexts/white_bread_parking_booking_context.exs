defmodule WhiteBread.Contexts.ParkingBookingContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Ecto.Query
  alias Parking.{Repo,Account.User,Account,Parking_place}

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

  given_ ~r/^Given that the following parking places are available$/, fn state, %{table_data: table} ->

    table
    |> Enum.map(fn p -> Parking_place.changeset(%Parking_place{}, p) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}

  end

  and_ ~r/^my location is "(?<location>[^"]+)" with latitude "(?<lat>[^"]+)" and longitude "(?<long>[^"]+)"$/,
  fn state, %{location: location, lat: lat, long: long} ->
    fill_field({:id, "user_lat"},lat)
    fill_field({:id, "user_long"},long)


    {:ok, state}
  end

  when_ ~r/^I click Book$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I must see an error message "(?<argument_one>[^"]+)" message.$/,fn state, %{argument_one: _argument_one} ->
    assert visible_in_page? ~r/We couldn't find a parking place near you!/
    {:ok, state}
  end




#############################################################################################




  given_ ~r/^Given that the following parking places are available$/, fn state, %{table_data: table} ->

    table
    |> Enum.map(fn p -> Parking_place.changeset(%Parking_place{}, p) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}

  end

  and_ ~r/^my location is "(?<location>[^"]+)" with latitude "(?<lat>[^"]+)" and longitude "(?<long>[^"]+)"$/,
  fn state, %{location: location, lat: lat, long: long} ->
    fill_field({:id, "user_lat"},lat)
    fill_field({:id, "user_long"},long)


    {:ok, state}
  end



  and_ ~r/^I choose "(?<argument_one>[^"]+)" payment method$/,
  fn state, %{argument_one: _argument_one} ->

    find_element(:id, "#payment_type option[value='HR']") |> click()
    {:ok, state}
  end


  and_ ~r/^I specify the intended leaving time 1 hour from now$/,
  fn state, %{argument_one: _argument_one} ->

    find_element(:id, "#booking_end_time_hour option[value='1']") |> click()
    {:ok, state}
  end


  when_ ~r/^I click Book$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end


  then_ ~r/^I must see "(?<argument_one>[^"]+)"$/,fn state, %{argument_one: _argument_one} ->
    assert visible_in_page? ~r/Booking created successfully.You can now park in 'Narva maante 18'/
    {:ok, state}
  end


  and_ ~r/^the number of busy places for '(?<address>[^"]+)' must be "(?<num>[^"]+)"$/, fn state, %{address: address,num: num} ->

    query = from p in Parking_place,
            where: p.address==^address and p.busy_places==^num
    check = Repo.exists?(query)
    cond do
      not check -> {:error,state}
      check -> {:ok,state}
    end
  end






######################################################################################







  given_ ~r/^Given that the following parking places are available$/, fn state, %{table_data: table} ->

    table
    |> Enum.map(fn p -> Parking_place.changeset(%Parking_place{}, p) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}

  end

  and_ ~r/^my location is "(?<location>[^"]+)" with latitude "(?<lat>[^"]+)" and longitude "(?<long>[^"]+)"$/,
  fn state, %{location: location, lat: lat, long: long} ->
    fill_field({:id, "user_lat"},lat)
    fill_field({:id, "user_long"},long)


    {:ok, state}
  end

  when_ ~r/^I click Book$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I must see "(?<argument_one>[^"]+)"$/,fn state, %{argument_one: _argument_one} ->
    assert visible_in_page? ~r/Oops,this parking place doesnt have any available space right now. Please find another one./
    {:ok, state}
  end







#######################################################################3






  given_ ~r/^Given that the following parking places are available$/, fn state, %{table_data: table} ->

    table
    |> Enum.map(fn p -> Parking_place.changeset(%Parking_place{}, p) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}


  end

  and_ ~r/^my location is "(?<location>[^"]+)" with latitude "(?<lat>[^"]+)" and longitude "(?<long>[^"]+)"$/,
  fn state, %{location: location, lat: lat, long: long} ->
    fill_field({:id, "user_lat"},lat)
    fill_field({:id, "user_long"},long)


    {:ok, state}
  end



  and_ ~r/^I choose "(?<argument_one>[^"]+)" payment method$/,
  fn state, %{argument_one: _argument_one} ->

    find_element(:id, "#payment_type option[value='RT']") |> click()
    {:ok, state}
  end




  when_ ~r/^I click Book$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I must see "(?<argument_one>[^"]+)"$/,fn state, %{argument_one: _argument_one} ->
    assert visible_in_page? ~r/Booking is successfull. You can now terminate your parking anytime by clicking Terminate'/
    {:ok, state}
  end



end
