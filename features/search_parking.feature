Feature: Searching parking place
    As a user I want to search for parking place

    Scenario: 
    Given that my email is "eraldo.keshi@hotmail.com"
    And I am logged in
    And the following prices correspond to the zones
    | Zone | Hourly | Real-time |
    | A | 2 | 16 |
    | B | 1 | 8 |

    And Given the following parking places are available
    | Name | Address | Zone | Nr of free spaces |
    | Delta Parking | Delta | A | 5
    | Raatuse P | Raatuse 18 | B | 10 |
    | LounaKeskus | Ringtee 75 | B | 10 |

    And Given that the following parking places are available
    And my destination address is Raatuse 22
    And I have not provided an intended leaving hour
    Then I should see information about Raatuse P in the screen
    And information must include information for number of free places, zone , zone Pricing , distance from destination address.