Feature: Book parking

Scenario: Booking a parking space when you are too far from the parking place

Given that I want to book the following parking space
| Name | Address | Zone | Nr of free spaces |
| Delta| Narva maantee 18, 51009, Tartu | A | 28 |
And my location is "Ringtee 75, 50501 Tartu"
And I click Book
And I choose "Hourly" payment method
And I specify the intended leaving time 1 hour from now
When I click Finish
Then I must see "You cannot book this parking space. You are too far from the parking place area."



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
And my location is ....
And I click Book
And I choose "Real Time" payment method
And I specify the intended leaving time 1 hour from now
When I click Finish
Then I must see "Booking is successfull. You can now park your car for 1 hour"
And the number of available parking spaces must be 1 less.


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






