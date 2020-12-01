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
    %{}
  end
  scenario_finalize fn _status, _state ->
    Repo.delete_all(Parking_place)

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

  and_ ~r/^the following prices correspond to the zones$/, fn state ->
    # [%{name: "A", hourly_rate: 2.0, realtime_rate: 0.16},
    #  %{name: "B", hourly_rate: 1.0, realtime_rate: 0.08}]
    # |> Enum.map(fn zone_data -> Zone.changeset(%Zone{}, zone_data) end)
    # |> Enum.each(fn change  information about Delta parking place in the screen implement withset -> Repo.insert!(changeset) end)

    query_a = from z in Zone,
              where: z.name=="A" and z.hourly_rate == 2.0 and z.realtime_rate == 0.16
    query_b = query_a = from z in Zone,
              where: z.name=="B" and z.hourly_rate == 1.0 and z.realtime_rate == 0.08

    zone_a_exists = Repo.exists?(query_a)
    zone_b_exists = Repo.exists?(query_b)

    cond do
      zone_a_exists and zone_b_exists -> {:ok, state}
      not zone_a_exists or not zone_b_exists -> {:error,state}
    end
    # it will passed because migrations of zones are done and they seeded to database so in actual test we will fetch from database

  end

  and_ ~r/^Given the following parking places are available$/, fn state ->
    # [%{name: "Delta", address: "Narva maantee 18, 51009, Tartu", total_places: 30, busy_places: 2},
    #  %{name: "Lounakeskus", address: "Ringtee 75, 50501 Tartu", total_places: 45, busy_places: 22},
    #  %{name: "Eeden", address: "Kalda tee 1c, 50104 Tartu", total_places: 35, busy_places: 13}]
    # |> Enum.map(fn parking_place_data -> Parking_place.changeset(%Parking_place{}, parking_place_data) end)
    # |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    query_delta = from z in Parking_place,
              where: z.name=="Delta"
    query_louna = query_a = from z in Parking_place,
              where: z.name=="Lounakeskus"
    query_eeden = query_a = from z in Parking_place,
              where: z.name=="Eeden"

    delta_exists = Repo.exists?(query_delta)
    louna_exists = Repo.exists?(query_louna)
    eeden_exists = Repo.exists?(query_louna)

    cond do
      delta_exists and louna_exists and eeden_exists -> {:ok, state}
      not delta_exists or not louna_exists or not eeden_exists -> {:error, state}
    end

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

  then_ ~r/^I should see "(?<argument_one>[^"]+)" message.$/,fn state, %{argument_one: _argument_one} ->
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

  when_ ~r/^I submit searhing request$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I should see "(?<argument_one>[^"]+)" message .$/,
  fn state, %{argument_one: _argument_one} ->
    # assert visible_in_page? ~r/Leaving hour can't be in the past/
    {:ok, state}
  end
end
