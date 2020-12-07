Feature: Extend Booking time payment

    Scenario: Driver extends booking time
    Given that I have booked a parking space
    And there are 8 minutes left until my booking time ends
    And the payment method is Hourly Payment
    And I click the extend link received in my email
    And I choose the new end time
    When I click Extend Parking Time
    And go to my invoices page
    Then I should see an invoice with status "PAID" on the screen.