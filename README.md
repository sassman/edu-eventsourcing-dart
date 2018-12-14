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

** Code notes

where we see how nice dart is and how less code is required get things done :)

```bash
.
├── README.md
├── analysis_options.yaml
├── lib
│   ├── event_sourcing_workshop.dart
│   └── src
│       ├── events.dart
│       └── models.dart
├── pubspec.lock
├── pubspec.yaml
└── test
    ├── events_test.dart
    └── models_test.dart
```

lib/src/events.dart contains all `DomainEvents`
lib/src/models.dart contains `ValueObjects` and `Aggregates`

run the tests by:

```bash
pub run test
```
