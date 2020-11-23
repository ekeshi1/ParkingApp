defmodule WhiteBread.Contexts.RegisterContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias Parking.{Repo}

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

  given_ ~r/^that I am an unregistered user/, fn state ->
    IO.puts("please log")
    {:ok, state}
  end

  and_ ~r/^my full name is "(?<name>[^"]+)"/, fn state,%{name: name} ->

    IO.inspect(name)
    {:ok, state |> Map.put(:name,name)}
  end

  and_ ~r/^my License Number is "(?<license>[^"]+)"/, fn state, %{license: license} ->
    IO.puts license
    {:ok, state |> Map.put(:license, license)}

  end


  and_ ~r/^my email is "(?<email>[^"]+)"/, fn state, %{email: email} ->
    IO.puts email
    {:ok, state |> Map.put(:email, email)}

  end


  and_ ~r/^my password is "(?<password>[^"]+)"/, fn state, %{password: password} ->
    IO.puts password
    {:ok, state |> Map.put(:password, password)}

  end

  and_ ~r/^I go to the login page/, fn state->
    navigate_to "/users/new"
    {:ok,state}
  end

  and_ ~r/^I fill all the fields/, fn state->
    fill_field({:id, "user_name"}, state[:name])
    fill_field({:id, "user_email"},state[:email])
    fill_field({:id, "user_license"}, state[:license])
    fill_field({:id, "user_password"}, state[:password])
    {:ok,state}
  end

  when_ ~r/^I click Register/, fn state ->
    IO.puts "Submited"
    click({:id, "register_button"})
    {:ok,state}
  end

  then_ ~r/^I must see "(?<success_msg>[^"]+)" appear in the screen/, fn state,%{success_msg: success_msg} ->
    assert visible_in_page? ~r/Successfully registered!/
    {:ok, state}
  end

  then_ ~r/^I should see "Invalid email!" in the screen/, fn state ->
    assert visible_in_page? ~r/Invalid email!/
    {:ok, state}
  end








end
