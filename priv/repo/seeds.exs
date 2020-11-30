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

# [

#   %{name: "Delta", address: "Narva maantee 18,51009,Tartu", total_places: 30, busy_places: 2, zone_id: "A"},
#  %{name: "Lounakeskus", address: "Ringtee 75,50501,Tartu", total_places: 45, busy_places: 22, zone_id: "A"},
#  %{name: "Eeden", address: "Kalda tee 1c, 50104,Tartu", total_places: 35, busy_places: 13, zone_id: "B"},
#  %{name: "Raatuse", address: "Raatuse 22,51009,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
#  %{name: "Lounakeskus 2", address: "Ringtee 75,50501,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
#  %{name: "Pikk", address: "Pikk 40,50630,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
#  %{name: "Narva 27", address: "Narva maantee 27,51009,Estonia", total_places: 30, busy_places: 2, zone_id: "A"},
# ]

[

  %{name: "Delta", address: "Narva maantee 18", total_places: 30, busy_places: 2, zone_id: "A" , lat: 58.390910, long: 26.729980},
 %{name: "Lounakeskus", address: "Ringtee 75", total_places: 45, busy_places: 22, zone_id: "A", lat: 58.358158, long: 26.680401},
 %{name: "Eeden", address: "Kalda tee 1c", total_places: 35, busy_places: 13, zone_id: "B", lat: 58.372800, long: 26.753930},
 %{name: "Raatuse", address: "Raatuse 22", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.382580, long: 26.732060},
 %{name: "Lounakeskus 2", address: "Ringtee 75", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3586092, long: 26.6765849},
 %{name: "Pikk", address: "Pikk 40", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.382213, long: 26.7355454},
 %{name: "Narva 27", address: "Narva maantee 27", total_places: 30, busy_places: 2, zone_id: "A", lat: 58.3965215, long: 26.735385},
]
|> Enum.map(fn parking_place_data -> Parking_place.changeset(%Parking_place{}, parking_place_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

[%{name: "Bob", license: "9999", email: "bob@gmail.com", password: "123"},
 %{name: "E", license: "11112", email: "erkesh@ttu.ee", password: "12345"},
 %{name: "Dave", license: "1111", email: "dave@gmail.com", password: "321"}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
