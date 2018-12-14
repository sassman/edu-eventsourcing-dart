** workshop from Anton about EventSourcing

Requirements

* the workshop is programming language agnostic
* if anybody want's to implement with Go but is not 100% fluid with it - I can support
* bring a laptop with a suitable development environment for your programming language
* you should be able to run (unit) tests
* nothing else, no database, no web framework

What we will try to implement

* an event-sourced aggregate: Person
* some value objects for a Person: Name, EmailAddress, Address
* some domain events: PersonRegistered, PersonEmailAddressConfirmed, PersonAddressAdded, PersonAddressChanged
* the methods in the Person aggregate which will cause the above events
* we'll try to work test-driven as much as possible
