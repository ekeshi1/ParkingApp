Feature: Driver Register

Scenario: Registering as a new and valid user.
Given that I am an unregistered user
And my full name is "Jan Klod"
And my License Number is "1311234" 
And my email is "jan.klod@hotmail.com"
And my password is "12345678"
And I go to the login page
And I fill all the fields
When I click Register
Then I must see a success message

Scenario: Registering as a driver with invalid email will fail. 
Given that I am an unregistered user
And my full name is "Jana Kesku"
And my License Number is "145631" 
And my email is "jana.kesku"
And my password is "12345678"
And I go to the login page
And I fill all the fields
When I click Register
Then I should see "Invalid email!" in the screen


Scenario: Registering with the same address as an already existing user will fail.
Given that there exists a user whose email address is "jan.klod@hotmail.com" 
And my full name is "Erald Keshi"
And my License Number is "1311234" 
And my email is "jan.klod@hotmail.com"
And my password is "12345678"
And I go to the login page
And I fill all the fields
When I click Register
Then I must see "A user already exists with this email!" in the screen


Scenario: Registering with the same license_number as an already existing user will fail.
Given that there exists a user whose license number is "1311234" 
And my full name is "Erald Keshi"
And my License Number is "1311234" 
And my email is "jan.klod@hotmail.com"
And my password is "12345678"
And I go to the login page
And I fill all the fields
When I click Register
Then I must see "A user already exists with this license!" in the screen
