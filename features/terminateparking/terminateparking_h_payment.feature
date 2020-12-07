Feature: Terminate parking
    As a driver I want to be able to terminate my parking so my parking time can end.

    Scenario: Terminating parking with hourly payment
    Given that I have booked a hourly parking space with no end time
    And I go to My Parkings page
    And I see my ongoing parking booking listed
    And I see a button "Terminate parking"
    When I click It 
    And go to my invoices page
    Then I should see an invoice with status "PAID" on the screen.
