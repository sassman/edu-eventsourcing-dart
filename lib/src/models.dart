import 'package:uuid/uuid.dart';
import 'events.dart';

class GivenNameIsEmpty implements Exception {}

class FamilyNameIsEmpty implements Exception {}

/// value object Name
class Name {
  /// public but immutable
  final String givenName;
  final String familyName;

  /// private constructor
  Name._(this.givenName, this.familyName);

  /// factory method that takes care of validation
  static Name ofGivenAndFamilyName(String givenName, String familyName) {
    final name = Name._(givenName, familyName);
    name._validate();
    return name;
  }

  /// factory method that does no validation
  static Name newWithoutValidation(String givenName, String familyName) {
    return Name._(givenName, familyName);
  }

  /// validation method
  void _validate() {
    if (givenName.isEmpty) {
      throw GivenNameIsEmpty();
    }
    if (familyName.isEmpty) {
      throw FamilyNameIsEmpty();
    }
  }
}

/// value object Id
class Id {
  final String id;

  Id._(this.id);

  static Id generate() {
    final uuid = Uuid();
    return Id._(uuid.v4());
  }
}

/// value object for an EmailAddress
class EmailAddress {
  final String email;
  final bool isConfirmed;

  EmailAddress._(this.email, this.isConfirmed);

  EmailAddress confirm() => EmailAddress._(email, true);

  static EmailAddress of(String email) {
    return EmailAddress._(email, false);
  }
}

/// value object for an Address
class Address {
  final String street;
  final String houseNumber;
  final String city;
  final String postalCode;
  final String countryCode;

  Address._(this.street, this.houseNumber, this.city, this.postalCode,
      this.countryCode);

  static Address of(String street, String houseNumber, String city,
      String postalCode, String countryCode) {
    return Address._(street, houseNumber, city, postalCode, countryCode);
  }
}

/// aggregate root Person
class Person {
  Id _id;
  Name _name;
  Address _homeAddress;
  EmailAddress _workMail;
  final List<DomainEvent> _recordedEvents = [];

  List<DomainEvent> get recordedEvents => _recordedEvents;

  Person._();

  static Person register(Id id, Name name, EmailAddress workMail) {
    // create internally the empty person
    final p = Person._();
    // create the registeredEvent
    final e = PersonRegistered.of(id, name, workMail);
    p._recordEvent(e);
    p._apply(e);
    return p;
  }

  static Person reconstitute(List<DomainEvent> events) {
    final p = Person._();
    for(DomainEvent e in events) {
      p._apply(e);
    }
    return p;
  }

  void confirmEmail() {
    if (_workMail.isConfirmed) {
      return;
    }
    final e = EmailAddressConfirmed.of(_id);
    _recordEvent(e);
    _apply(e);
  }

  void _recordEvent(DomainEvent e) => _recordedEvents.add(e);

  void _apply(DomainEvent e) {
    if (e.payload is PersonRegistered) {
      _whenPersonRegistered(e);
    }
    if (e.payload is EmailAddressConfirmed) {
      _whenEmailAddressConfirmed(e);
    }
  }

  void _whenPersonRegistered(DomainEvent<PersonRegistered> e) {
    _id = e.payload.id;
    _name = e.payload.name;
    _workMail = e.payload.email;
  }

  void _whenEmailAddressConfirmed(DomainEvent<EmailAddressConfirmed> e) {
    if (e.payload.id == _id) {
      _workMail = _workMail.confirm();
    }
  }
}
