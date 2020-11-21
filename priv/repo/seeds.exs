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
alias Parking.{Repo, Places.Zone, Places.Parking_place}

[%{name: "A", hourly_rate: 2.0, realtime_rate: 0.16},
 %{name: "B", hourly_rate: 1.0, realtime_rate: 0.8}]
|> Enum.map(fn zone_data -> Zone.changeset(%Zone{}, zone_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

[%{name: "Delta", address: "Narva mnt 18", total_places: 30, busy_places: 2},
 %{name: "Lõunakeskus", address: "Ringtee 75", total_places: 45, busy_places: 22},
 %{name: "Eeden", address: "Kalda tee 1c", total_places: 35, busy_places: 13}]
|> Enum.map(fn parking_place_data -> Parking_place.changeset(%Parking_place{}, parking_place_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
