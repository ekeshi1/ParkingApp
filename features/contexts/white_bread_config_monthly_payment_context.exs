defmodule WhiteBread.Contexts.MonthlyPaymentContext do
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

  given_ ~r/^that I am logged In$/, fn state ->
    navigate_to "/sessions/new"

    Account.create_user(%{email: "a@gmail.com", license: "3454567890", name: "some name", password: "123", monthly_payment: false})

    case search_element(:id, "email",2) do
      {:ok,_elem} ->
        fill_field({:id, "email"}, "a@gmail.com")
        fill_field({:id, "password"}, "123")
        click({:id, "login_button"})
        {:ok,state}

      {:error ,_s}->    {:ok,state}

    end
  end

  and_ ~r/^I go to the profile page$/, fn state ->
    navigate_to "/users"
    {:ok, state}
  end

  and_ ~r/^I Click "(?<button_id>[^"]+)"$/, fn state, %{button_id: button_id} ->
    click({:id, button_id})
    {:ok, state}
  end

  then_ ~r/^I should see "(?<message>[^"]+)" on the screen$/, fn state, %{message: message} ->
    assert visible_in_page? Regex.compile!(message)
    {:ok, state}
  end

end
