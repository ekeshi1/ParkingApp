Feature: Searching parking place
    As a user I want to search for parking place

    Scenario: Searching parking (with succesfull result with description)
        Given that my email is "eraldo.keshi@hotmail.com" and password is "123456"
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
        And I have not provided an intended leaving hour
        When I submit searching request
        Then I should see information about Delta parking place in the screen
        And information must include information for number of free places, zone , zone Pricing , distance from destination address, and amount to be paid for Hourly and real time payment.

    Scenario: Searching parking (with time error)
        Given that my email is "eraldo.keshi@hotmail.com" and password is "123456"
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
        And my intended leaving hour is 1 hour before now
        When I submit searhing request
        Then I should see "Leaving hour can't be in the past message" .


