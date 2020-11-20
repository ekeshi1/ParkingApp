DDEFeature: Registration
    As a user I want to register on the webpage


    Scenario: Registration on webb (with succesfull message)
        GIven that I am an unregistered user
        And my full name is "Jan Klod"
        And my License Number is "1311234" 
        And my email is "jan.klod@hotmail.com"
        And my password is "11134"
        And I fill all the fields
        When I click Submit
        Then I must see "Successfully registered" appear in the screen
        And the user must be registered in the database.

    Scenario: Registration on web (with invalid email error)
        Given that I am an unregistered user
        And my full name is "Jana Kesku"
        And my License Number is "145631" 
        And my email is "jana.kesku"
        And my password is "11134"
        And I fill all the fields
        When I click Submit
        Then I should see "Invalid email" in the screen
        And the user must not be registered in the database.


    Scenario: Registration on web (with user already exists message)
        Given that there exists a user whose email address is "jan.klod@hotmail.com" 
        And my name is "Erald Keshi"
        And my License Number is "1311234" 
        And my email is "jan.klod@hotmail.com"
        And my password is "11134"
        And I fill all the fields
        When I click Submit
        Then I must see "User already exists" in the screen
        And the user must not be registered.