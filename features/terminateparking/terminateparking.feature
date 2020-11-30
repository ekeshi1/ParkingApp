Feature: Terminate parking
    As a driver I want to be able to terminate my parking so my parking time can end.

    Scenario: Terminating parking 
    Given that I have booked a real time parking space
    And I haven't specified an end time
    And I go to My Parkings page
    And I see my ongoing parking booking listed
    And I see a button "Terminate parking"
    When I click It 
    Then I should see a "Booking Terminated. Total Fee is " Message 
    And the corresponding row in the list must be updated accordingly.
