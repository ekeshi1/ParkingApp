Feature: Book parking

Scenario: Booking a parking space when you are too far(more than  km) from the parking place.

Given that I am logged in
And that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Lounakeskus | Ringtee 75 | A | 45 | 23 | 58.358158 | 26.680401|
| Lounakeskus 2| Ringtee 74 | A | 42 | 41 | 58.3586092 | 26.6765849 |
And I navigate to new bookings page
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
When I click Book
Then I must see an error message "We couldn't find a parking place near you!"


Scenario: Booking a parking space when you are close enough(less than 0.5km) to a parking place with no free spaces must fail
Given that I am logged in
And I navigate to new bookings page
And that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 30 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
When I click Book
Then I must see "Oops,this parking place doesnt have any available space right now. Please find another one."

Scenario: Booking a Real time parking space without specifying end time should be successfull

Given that I am logged in
And I navigate to new bookings page
Given that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 28 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Real-Time" payment method
And I click Book
Then I must see "Booking is successfull. You can now terminate your parking in 'Narva maantee 18' anytime by clicking Terminate Parking in your bookings."
And Total amount must be "-"
And End time should not be specified


Given that I am logged in
And I navigate to new bookings page
Given that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 28 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Real-Time" payment method
And I specify ending time 1 hour from now
And I click Book
Then I must see "Booking created successfully.You can now park in 'Narva maante 18'"
And Total amount must be calculated
And End time should be specified




Scenario: Booking a parking space when you are close enough(less than 0.5km) to the parking place

Given that I am logged in
And that the following parking places are available
| name | address | zone_id | total_places | busy_places | lat | long |
| Delta| Narva maantee 18 | A | 30 | 2 | 58.390910 | 26.729980 |
And I navigate to new bookings page
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Hourly" payment method
When I click Book
Then I must see "Booking is successfull. You can now terminate your parking in 'Narva maantee 18' anytime by clicking Terminate Parking in your bookings."
