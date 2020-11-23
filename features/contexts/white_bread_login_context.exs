defmodule WhiteBread.Contexts.LoginContext do
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


  given_ ~r/^that I am a registered user "(?<email>[^"]+)" with password "(?<password>[^"]+)"$/,
  fn state, %{email: email, password: password} ->

    case Account.create_user(%{name: "Eraldo", license: "8534", email: email, password: password}) do
      {:ok, user} ->
        IO.puts("created user")
        {:ok, state}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Couldnt create user")
        {:error, state}
    end
  end

  given_ ~r/^that user "(?<email>[^"]+)" is not registered$/, fn state, %{email: email} ->

    query = from u in User,
            where: u.email==^email
    user_exists = Repo.exists?(query)
    cond do
      user_exists -> {:error,state}
      not user_exists -> {:ok,state}
    end
  end

  when_ ~r/^I go to the login page$/, fn state ->
    navigate_to "/sessions/new"
    {:ok, state}
  end

  and_ ~r/^I fill email as  "(?<email>[^"]+)"$/, fn state, %{email: email} ->
    fill_field({:id, "email"}, email)
    {:ok, state}
  end

  and_ ~r/^I fill password as "(?<password>[^"]+)"$/, fn state, %{password: password} ->
    fill_field({:id, "password"}, password)
    {:ok, state}
  end

  and_ ~r/^I click Login$/, fn state ->
    click({:id, "login_button"})
    {:ok, state}
  end

  then_ ~r/^I must see "(?<message>[^"]+)" in the screen. $/, fn state, %{message: message} ->
    assert visible_in_page? Regex.compile!(message)
    {:ok, state}
  end

end
