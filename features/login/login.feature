Feature: Login
    As a driver 
    I want to be able to input my email and password
    so that I can login into the app

    Scenario: Logging in (with successful message)
        Given that I am a registered user "eraldo.keshi@Hotmail.com" with password "11134"
        When I go to the login page
        And I fill email as  "eraldo.keshi@Hotmail.com"
        And I fill password as "11134"
        And I click Login
        Then I must see "Successfully logged in" in the screen. 

    Scenario: Logging in (with user doesn't exist message)
        Given that user "somedude@Hotmail.com" is not registered
        When I go to the login page
        And I fill email as  "somedude@Hotmail.com"
        And I fill password as "21312"
        And I click Login
        Then I must see "User doesn't exist" in the screen. 

    Scenario: Logging in (with wrong password message)
        Given that I am a registered user "eraldo.keshi@Hotmail.com" with password "11134"
        When I go to the login page
        And I fill email as  "eraldo.keshi@Hotmail.com"
        And I fill password as "21315"
        And I click Login
        Then I must see "Wrong password! Please try again" in the screen. 
