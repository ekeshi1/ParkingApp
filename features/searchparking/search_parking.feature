Feature: Searching parking place
    As a user I want to search for parking place

    Scenario: Searching parking (with giving time of parking)
        Given that my email is "bob@gmail.com" and password is "123"
        And I am logged in
        And the following prices correspond to the zones
        | Zone | Hourly | Real-time |
        | A | 2 | 16 |
        | B | 1 | 8 |

        And Given the following parking places are available
        | Name | Address | Zone | Nr of free spaces |
        | Delta| Narva maantee 18, 51009, Tartu | A | 28 |
        | Eeden | Kalda tee 1c, 50104 Tartu | B | 22 |
        | LounaKeskus | Ringtee 75, 50501 Tartu | B | 23 |
        
        And I open searching parking place page
        And my destination address is "Raatuse 22"
        And I have not provided an intended leaving hour
        When I submit searching request
        Then I should see "Here are the available parking zones." message.
        
    Scenario: Searching parking (with giving time)
        Given that my email is "bob@gmail.com" and password is "123"
        And I am logged in
        And the following prices correspond to the zones
        | Zone | Hourly | Real-time |
        | A | 2 | 16 |
        | B | 1 | 8 |

        And Given the following parking places are available
        | Name | Address | Zone | Nr of free spaces |
        | Delta| Narva maantee 18, 51009, Tartu | A | 28 |
        | Eeden | Kalda tee 1c, 50104 Tartu | B | 22 |
        | LounaKeskus | ingtee 75, 50501 Tartu | B | 23 |

        And I open searching parking place page
        And my destination address is "Raatuse 22"
        And my intended parking time "1" hour and "20" minutes
        When I submit searhing request
        Then I should see "Information about parking places without estimated price" message .


