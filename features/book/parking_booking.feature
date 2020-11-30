Feature: Book parking

Scenario: Booking a parking space when you are too far from it.

Given that I want to book the following parking space
| Name | Address | Zone | Nr of free spaces |
| Delta| Narva maantee 18, 51009, Tartu | A | 28 |
And my location is "Ringtee 75" with latitude "xx" and longitude "yy"
And I choose "Hourly" payment method
And I specify the intended leaving time 1 hour from now
And I click Book
When I click Finish
Then I must see "Booking created successfully"
And I must see my active Booking in the screen and the total_amount should be present





Scenario: Booking a parking space when you are close enough to the parking place

Given that I want to book the following parking space
| Name | Address | Zone | Nr of free spaces |
| Delta| Narva maantee 18, 51009, Tartu | A | 28 |
And my location is "Narva maantee 17, 51009, Tartu"
And I click Book
And I choose "Hourly" payment method
And I specify the intended leaving time 1 hour from now
When I click Finish
Then I must see "Booking is successfull. You can now park your car for 1 hour"



Scenario: Booking a parking space real time successfully updates number of available parking spaces.
Given that I want to book the following parking space
And my location is 
And I click Book
And I choose "Real Time" payment method
And I specify the intended leaving time 1 hour from now
When I click Finish
Then I must see "Booking is successfull. You can now park your car for 1 hour"
And the number of available parking spaces must be 1 less.
And Amount is calculated


Scenario: Booking a parking space without specifying end time should show Terminate Parking in the bookings list
Given that I want to book the following parking space
And my location is 
And I click Book
And I choose "Real Time" payment method
And I specify the intended leaving time 1 hour from now
When I click Finish
Then I must see "Booking is successfull. You can now terminate your parking anytime by clicking Terminate"
And the number of available parking spaces must be 1 less.
And Amount is calculated


Scenario: Booking without specifying ending time 
Given that I want to book the following parking space
| Name | Address | Zone | Nr of free spaces |
| Delta| Narva maantee 18, 51009, Tartu | A | 28 |
And my location is "Ringtee 75, 50501 Tartu"
And I click Book
And I choose "Real Time" payment method
And I don't specify an ending time
When I click Finish
Then I must see "Booking is successfull. You can now park your car for 1 hour"
And the number of available parking spaces must be 1 less.






