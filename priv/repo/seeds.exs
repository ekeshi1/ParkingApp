# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Parking.Repo.insert!(%Parking.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Parking.{Repo, Places.Zone, Places.Parking_place, Account.User}

[%{name: "A", hourly_rate: 2.0, realtime_rate: 0.16},
 %{name: "B", hourly_rate: 1.0, realtime_rate: 0.08}]
|> Enum.map(fn zone_data -> Zone.changeset(%Zone{}, zone_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

[

  %{name: "Delta", address: "Narva maantee 18,51009,Tartu", total_places: 30, busy_places: 2, zone_id: "A"},
 %{name: "Lounakeskus", address: "Ringtee 75,50501,Tartu", total_places: 45, busy_places: 22, zone_id: "A"},
 %{name: "Eeden", address: "Kalda tee 1c, 50104,Tartu", total_places: 35, busy_places: 13, zone_id: "B"},
 %{name: "Raatuse", address: "Raatuse 22,51009,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
 %{name: "Lounakeskus 2", address: "Ringtee 75,50501,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
 %{name: "Pikk", address: "Pikk 40,50630,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
 %{name: "Narva 27", address: "Narva mnt 27,51013,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
]
|> Enum.map(fn parking_place_data -> Parking_place.changeset(%Parking_place{}, parking_place_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

[%{name: "Bob", license: "9999", email: "bob@gmail.com", password: "123"},
 %{name: "E", license: "11112", email: "erkesh@ttu.ee", password: "12345"},
 %{name: "Dave", license: "1111", email: "dave@gmail.com", password: "321"}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
