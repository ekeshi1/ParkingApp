
"""
# REAL-TIME PAYMENT FEATURES
Feature: Parking payment for Hourly

Scenario: As a driver I want to not be debited when I have configured Monthly Payment and I book a real time parking place.

Given that I am logged in
And I have '50' euros in my account
And I have configured "Monthly Payment" in my profile
And I navigate to new bookings page
Given that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 28 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Real-Time" payment method
And I click Book
Then I must see "Booking is successfull. You can now terminate your parking in 'Narva maantee 18' anytime by clicking Terminate Parking in your bookings."
And I shouldn't see a generated invoice in the screen


Scenario: As a driver I want to  be debited immediately when I have configured Each booking payment and I book a real time parking place with a specific end time.

Given that I am logged in
And I have '50' euros in my account
And I have configured "Each Parking" in my profile
And I navigate to new bookings page
Given that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 28 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Real-Time" payment method
And I specify ending time 1 hour from now
And I click Book
Then I must see "Booking created successfully.You can now park in 'Narva maante 18'"
And I must see an invoice with status "Paid" in the screen

Scenario: As a driver I want to  be debited only when I Terminate parking when I have configured Each booking payment and I book a real time parking place without a specific end time.

Given that I am logged in
And I have '50' euros in my account
And I have configured "Each Parking" in my profile
And I navigate to new bookings page
Given that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 28 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Real-Time" payment method
And I click Book
Then I must see "Booking created successfully.You can now park in 'Narva maante 18'"
And I shouldn't see a generated invoice in the screen

Given that I am logged in
And I have '50' euros in my account
And I have configured "Each Parking" in my profile
And I already have an active booking
And I go to "/bookings"
And I click Terminate on that booking
And I click View Booking on that booking
And I must see an invoice with status "Paid" in the screen


"""






