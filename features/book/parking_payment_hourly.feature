

Feature: Parking payment for Hourly

#HOURLY PAYMENT FEATURES
Scenario: As a driver I want to pay for a hourly parking place with a specific end time booking before starting parking.  

Given that I am logged in
And I have "50" euros in my account
And I navigate to new bookings page
Given that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 28 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Hourly" payment method
And I specify ending time 1 hour from now
And I click Book
Then I must see "Booking created successfully.You can now park in 'Narva maante 18'"
And I navigate to invoices
And I must see an invoice with status "Paid" in the screen


Scenario: As a driver I want to pay for a hourly parking place without a specific end time booking when I terminate booking.  

Given that I am logged in
And I have "50" euros in my account
And I navigate to new bookings page
Given that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 28 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Hourly" payment method
And I click Book
Then I must see "Booking created successfully.You can now park in 'Narva maante 18'"
And I navigate to invoices
And I shouldn't see an invoice in the screen























