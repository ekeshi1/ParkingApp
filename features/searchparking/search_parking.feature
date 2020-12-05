Feature: Searching parking place
    As a user I want to search for parking place

    Scenario: Searching parking with address shows parking places
        Given that my email is "bob@gmail.com" and password is "123"
        And I am logged in
        And the following prices correspond to the zones
        | name | hourly_rate | realtime_rate |
        | A | 2 | 16 |
        | B | 1 | 8 |

        And Given the following parking places are available
        | name | address | zone_id | total_places | busy_places | lat | long |
        | Delta| Narva maantee 18 | A | 30 | 2 | 58.390910 | 26.729980 |
        | Pikk| Pikk 18 | A | 30 | 30 | 58.390910 | 26.3232 |
        | Tasku| Tasku 18 | A | 30 | 23 | 58.3909103 | 26.729980 |
        And I open searching parking place page
        And my destination address is "Raatuse 22"
        And I have not provided an intended leaving hour
        When I submit searching request
        Then I should see "Here are the available parking zones." message .
        
    Scenario: Searching parking (without time) shows available places and prices for hourly and real time
        Given that my email is "bob@gmail.com" and password is "123"
        And I am logged in
        And the following prices correspond to the zones
        | name | hourly_rate | realtime_rate |
        | A | 2 | 16 |
        | B | 1 | 8 |

        And Given the following parking places are available
        | name | address | zone_id | total_places | busy_places | lat | long |
        | Delta| Narva maantee 18 | A | 30 | 2 | 58.390910 | 26.729980 |
        | Pikk| Pikk 18 | A | 30 | 30 | 58.390910 | 26.3232 |
        | Tasku| Tasku 18 | A | 30 | 23 | 58.3909103 | 26.729980 |
        And I open searching parking place page
        And my destination address is "Raatuse 22"
        And I have not provided an intended leaving hour
        When I submit searching request
        Then I should see "Here are the available parking zones." message .
        And number of available places should be specified
        And prices(rates) for hourly and real time should be specified


    Scenario: Searching parking (with time) shows estimated fees for hourly and real time
        Given that my email is "bob@gmail.com" and password is "123"
        And I am logged in
        And the following prices correspond to the zones
        | name | hourly_rate | realtime_rate |
        | A | 2 | 16 |
        | B | 1 | 8 |

        And Given the following parking places are available
        | name | address | zone_id | total_places | busy_places | lat | long |
        | Delta| Narva maantee 18 | A | 30 | 2 | 58.390910 | 26.729980 |
        | Pikk| Pikk 18 | A | 30 | 30 | 58.390910 | 26.3232 |
        | Tasku| Tasku 18 | A | 30 | 23 | 58.3909103 | 26.729980 |
        And I open searching parking place page
        And my destination address is "Raatuse 22"
        And my intended parking time "1" hour and "20" minutes
        When I submit searching request
        Then I should see "Here are the available parking zones." message .
        And the estimated fee for hourly and real time should be specified
        