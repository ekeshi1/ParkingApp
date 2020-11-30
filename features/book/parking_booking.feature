Feature: Book parking

Scenario: Booking a parking space when you are too far(more than  km) from the parking place.

Given that the following parking places are available
| Name | Address | Zone | Total Places | Busy Places | Lat | Long |
| Lounakeskus | Ringtee 75 | A | 45 | 23 | 58.358158 | 26.680401|
| Lounakeskus 2| Ringtee 74 | A | 42 | 41 | 58.3586092 | 26.6765849 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
When I click Book
Then I must see an error message "We couldn't find a parking place near you!"





Scenario: Booking a parking space when you are close enough(less than 0.5km) to the parking place

Given that the following parking places are available
| Name | Address | Zone | Total Places | Busy Places | Lat | Long |
| Delta| Narva maantee 18 | A | 30 | 2 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I choose "Hourly" payment method
When I click Book
And I specify the intended leaving time 1 hour from now
When I click Finish
Then I must see "Booking created successfully.You can now park in 'Narva maante 18'"
And the number of busy places for 'Narva maante 18' must be "3" 






Scenario: Booking a parking space when you are close enough(less than 0.5km) to a parking place with no free spaces must fail
Given that the following parking places are available
| Name | Address | Zone | Total Places | Busy Places | Lat | Long |
| Delta| Narva maantee 18 | A | 30 | 30 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
When I click Book
Then I must see "Oops,this parking place doesnt have any available space right now. Please find another one."





Scenario: Booking a parking space without specifying end time should show Terminate Parking in the bookings list

Given that the following parking places are available
| Name | Address | Zone | Total Places | Busy Places | Lat | Long |
| Delta| Narva maantee 18 | A | 30 | 30 | 58.390910 | 26.729980 |
And my location is "Raatuse 21" with latitude "58.3825317" and longitude "26.7312859"
And I click Book
And I choose "Real Time" payment method
When I click Book
Then I must see "Booking is successfull. You can now terminate your parking anytime by clicking Terminate"
And the number of available parking spaces must be 1 less.
And Total amount must be "0.0"
And End time should not be specified
And I should see terminate parking in my screen.





Scenario: Booking a parking space without specifying while having an active parking should fail.
Given that I have an existing active bookings
When I try to go "/bookings/new"
Then I should see "You cant create another booking.You already have an active one."








