defmodule WhiteBread.Contexts.SearchParkingContext do
  use WhiteBread.Context
  use Hound.Helpers

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
    Ecto.Adapters.SQL.Sandbox.checkin(Parking.Repo)
    Hound.end_session
  end

  given_ ~r/^that my email is "(?<email>[^"]+)" and password is "(?<password>[^"]+)"/,
  fn state, %{email: email,password: password} ->
    {:ok, state |> Map.put(:email, email)
                |> Map.put(:password, password)}
  end

  and_ ~r/^I am logged in$/, fn state ->
    # navigate_to "/login"
    # fill_field({:id, "email"}, state[:email])
    # fill_field({:id, "password"}, state[:password])
    # click({:id, "login_button"})
    #TODO: Log in user
    {:ok, state}
  end

  and_ ~r/^the following prices correspond to the zones$/, fn state ->
    # [%{name: "A", hourly_rate: 2.0, realtime_rate: 0.16},
    #  %{name: "B", hourly_rate: 1.0, realtime_rate: 0.8}]
    # |> Enum.map(fn zone_data -> Zone.changeset(%Zone{}, zone_data) end)
    # |> Enum.each(fn change  information about Delta parking place in the screen implement withset -> Repo.insert!(changeset) end)
    # it will passed because migrations of zones are done and they seeded to database so in actual test we will fetch from database
    {:ok, state}
  end

  and_ ~r/^Given the following parking places are available$/, fn state ->
    # [%{name: "Delta", address: "Narva maantee 18, 51009, Tartu", total_places: 30, busy_places: 2},
    #  %{name: "Lounakeskus", address: "Ringtee 75, 50501 Tartu", total_places: 45, busy_places: 22},
    #  %{name: "Eeden", address: "Kalda tee 1c, 50104 Tartu", total_places: 35, busy_places: 13}]
    # |> Enum.map(fn parking_place_data -> Parking_place.changeset(%Parking_place{}, parking_place_data) end)
    # |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}

  end

  and_ ~r/^I open searching parking place page$/, fn state ->
    # navigate_to "/login"
    {:ok, state}
  end

  and_ ~r/^my destination address is "(?<destination>[^"]+)"$/,
  fn state, %{destination: destination} ->
    # fill_field({:id, "search_box"},destination)
    {:ok, state}
  end

  and_ ~r/^I have not provided an intended leaving hour$/, fn state ->
    # keeping empty field of leaving hour
    {:ok, state}
  end

  when_ ~r/^I submit searching request$/, fn state ->
    # click({:id, "submit"})
    {:ok, state}
  end
  then_ ~r/^I should see information about Delta parking place in the screen$/, fn state ->
    # assert visible_in_page? ~r/Delta/
    {:ok, state}
  end

  and_ ~r/^information must include information for number of free places, zone , zone Pricing , distance from destination address, and amount to be paid for Hourly and real time payment.$/, fn state ->
    # assert visible_in_page? ~r/free places/
    # assert visible_in_page? ~r/zone/
    # assert visible_in_page? ~r/hourly rate/
    # assert visible_in_page? ~r/realtime rate/
    # assert visible_in_page? ~r/distance/
    # assert visible_in_page? ~r/amount/
    {:ok, state}
  end

  and_ ~r/^my intended leaving hour is 1 hour before now$/, fn state ->
    {:ok, state}
  end

  when_ ~r/^I submit searhing request$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I should see "(?<argument_one>[^"]+)" message .$/,
  fn state, %{argument_one: _argument_one} ->
    # assert visible_in_page? ~r/Leaving hour can't be in the past/
    {:ok, state}
  end
end
