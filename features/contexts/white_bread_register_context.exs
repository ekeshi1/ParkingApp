defmodule WhiteBread.Contexts.RegisterContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Ecto.Query
  alias Parking.{Repo,Account.User,Account}

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

  given_ ~r/^that I am an unregistered user/, fn state ->
    IO.puts("please log")
    {:ok, state}
  end

  given_ ~r/^that there exists a user whose email address is "(?<already_existing_email>[^"]+)"/, fn state,%{already_existing_email: already_existing_email} ->
    query = from u in User,
            where: u.email==^already_existing_email
    case Account.create_user(%{name: "Erald", license: "1231", email: "jan.klod@hotmail.com", password: "123456"}) do
      {:ok, user} ->
        IO.puts("created user")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Couldnt create user")
    end
    user_exists = Repo.exists?(query)
    IO.puts user_exists
    cond do
      user_exists -> {:ok,state}
      not user_exists -> {:error,state}
    end
  end

  given_ ~r/^that there exists a user whose license number is "(?<already_existing_license>[^"]+)"/, fn state, %{already_existing_license: already_existing_license}->
    query = from u in User,
            where: u.license==^already_existing_license
    case Account.create_user(%{name: "Erald", license: already_existing_license, email: "janaaa.klod@hotmail.com", password: "123456"}) do
      {:ok, user} ->
        IO.puts("created user")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Couldnt create user")
    end
    user_exists = Repo.exists?(query)
    IO.puts user_exists
    cond do
      user_exists -> {:ok,state}
      not user_exists -> {:error,state}
    end
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



  then_ ~r/^I must see a success message/, fn state ->
    assert visible_in_page? ~r/Successfully registered!/
    {:ok, state}
  end

  then_ ~r/^I should see "Invalid email!" in the screen/, fn state ->
    assert visible_in_page? ~r/Invalid email!/
    {:ok, state}
  end

  then_ ~r/I must see "A user already exists with this email!" in the screen/, fn state ->
    assert visible_in_page? ~r/A user already exists with this email!/
    {:ok,state}
  end
  then_ ~r/I must see "A user already exists with this license!" in the screen/, fn state ->
    assert visible_in_page? ~r/A user already exists with this license!/
    {:ok,state}
  end


end
