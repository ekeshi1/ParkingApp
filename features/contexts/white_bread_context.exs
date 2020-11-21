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
    Hound.end_session
  end

  given_ ~r/^that my email is "(?<email>[^"]+)" and password is "(?<password>[^"]+)"$/,
  fn state, %{email: email,password: password} ->
    {:ok, state |> Map.put(:email, email)
                |> Map.put(:password, password)}
  end

  and_ ~r/^I am logged in$/, fn state ->
    #navigate_to "/search"
    # fill_field({:id, "email"}, state[:email])
    # fill_field({:id, "password"}, state[:password])
    # click({:id, "login_button"})
    #TODO: Log in user
    {:ok, state}
  end

  and_ ~r/^the following prices correspond to the zones$/, fn state ->
    {:ok, state}
  end
  # The skleton of the steps would be here
end
