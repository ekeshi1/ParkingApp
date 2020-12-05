defmodule WhiteBread.Contexts.SearchParkingContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Ecto.Query
  alias Parking.{Repo, Places.Parking_place, Places.Zone}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end
  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Parking.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Parking.Repo, {:shared, self()})
    %{}
  end
  scenario_finalize fn _status, _state ->
    #Repo.delete_all(Parking_place)

    Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo)

    Hound.end_session
  end

  given_ ~r/^that my email is "(?<email>[^"]+)" and password is "(?<password>[^"]+)"/,
  fn state, %{email: _email,password: _password} ->
    {:ok, state |> Map.put(:email, _email)
                |> Map.put(:password, _password)}
  end

  and_ ~r/^I am logged in$/, fn state ->
    navigate_to "/sessions/new"
    fill_field({:id, "email"}, state[:email])
    fill_field({:id, "password"}, state[:password])
    click({:id, "login_button"})
    #TODO: Log in user
    {:ok, state}
  end

  and_ ~r/^the following prices correspond to the zones$/, fn state, %{table_data: table}->
    table
    |> Enum.map(fn p ->
      Zone.changeset(%Zone{}, p) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}

  end

  and_ ~r/^Given the following parking places are available$/, fn state, %{table_data: table} ->
    IO.puts("first")
    table
    |> Enum.map(fn p ->
      Parking_place.changeset(%Parking_place{}, p) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}

  end

  and_ ~r/^I open searching parking place page$/, fn state ->
    navigate_to "/search"
    {:ok, state}
  end

  and_ ~r/^my destination address is "(?<destination>[^"]+)"$/,
  fn state, %{destination: destination} ->
    fill_field({:id, "destination_address"},destination)
    {:ok, state}
  end

  and_ ~r/^I have not provided an intended leaving hour$/, fn state ->
    # keeping empty field of leaving hour
    {:ok, state}
  end

  when_ ~r/^I submit searching request$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end


  # then_ ~r/^I should see information about Delta parking place in the screen$/, fn state ->
  #   assert visible_in_page? ~r/Here are the available parking zones./
  #   {:ok, state}
  # end

  then_ ~r/^I should see "Here are the available parking zones." message .$/,fn state ->
    assert visible_in_page? ~r/Here are the available parking zones./
    {:ok, state}
  end

  # and_ ~r/^information must include information for number of free places, zone , zone Pricing , distance from destination address, and amount to be paid for Hourly and real time payment.$/, fn state ->
  #   assert visible_in_page? ~r/free places/
  #   assert visible_in_page? ~r/zone/
  #   assert visible_in_page? ~r/hourly rate/
  #   assert visible_in_page? ~r/realtime rate/
  #   assert visible_in_page? ~r/distance/
  #   assert visible_in_page? ~r/amount/
  #   {:ok, state}
  # end

  and_ ~r/^my intended parking time "(?<hours>[^"]+)" hour and "(?<minutes>[^"]+)" minutes$/,
  fn state, %{hours: h,minutes: m} ->
    fill_field({:id, "hours"},h)
    fill_field({:id, "minutes"},m)
    {:ok, state}
  end

  and_ ~r/^number of available places should be specified$/, fn state ->
    assert inner_text({:id,"available_places"}) != ""
    {:ok, state}
  end

  and_ ~r/^prices(rates) for hourly and real time should be specified$/, fn state ->
    assert inner_text({:id,"hour_rate"}) != ""
    assert inner_text({:id,"realtime_rate"}) != ""
    {:ok, state}
  end

  and_ ~r/^the estimated fee for hourly and real time should be specified$/, fn state ->
    assert inner_text({:id,"hour_price"}) != ""
    assert inner_text({:id,"realtime_price"}) != ""
    {:ok, state}
  end

end
