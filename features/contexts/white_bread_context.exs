defmodule WhiteBreadContext do
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
    # Hound.end_session
  end

  given_ ~r/^that my email is "(?<email>[^"]+)" and password is "(?<password>[^"]+)"$/,
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
    # |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
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

  # ---------------------------------------------------------------------------------------
  # LOGIN
  given_ ~r/^that I am a registered user "(?<argument_one>[^"]+)" with password "(?<argument_two>[^"]+)"$/,
  fn state, %{argument_one: _argument_one,argument_two: _argument_two} ->
    {:ok, state}
  end

  given_ ~r/^that user "(?<argument_one>[^"]+)" is not registered$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  when_ ~r/^I go to the login page$/, fn state ->
    #navigate_to "/user/login"
    {:ok, state}
  end

  and_ ~r/^I fill email as  "(?<argument_one>[^"]+)"$/, fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^I fill password as "(?<argument_one>[^"]+)"$/, fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^I click Login$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I must see "(?<argument_one>[^"]+)" in the screen. $/, fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end
end
