Feature: Terminate parking
    As a driver I want to be able to terminate my parking so my parking time can end.

    Scenario: Terminating parking with real-time payment and immediate debit
    Given I have configured "Pay on each parking" in my profile
    Given that I have booked a real time parking space with no end time
    And I go to My Parkings page
    And I see my ongoing parking booking listed
    And I see a button "Terminate parking"
    When I click It 
    And go to my invoices page
    Then I should see an invoice with status "PAID" on the screen.
