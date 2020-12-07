Feature: Configureing monthly payment

    Scenario: "User chooses to pay monthly"
        Given that I am logged In
        And I go to the profile page
        And I Click "Pay monthly"
        Then I should see "You're configured to pay for your parkings at the end of the month." on the screen