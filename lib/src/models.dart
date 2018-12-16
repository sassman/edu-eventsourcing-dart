import 'package:uuid/uuid.dart';
import 'events.dart';

class GivenNameIsEmpty implements Exception {}

class FamilyNameIsEmpty implements Exception {}

/// value object Name
class Name {
  /// public but immutable
  final String givenName, familyName;

  /// named constructor without a body
  const Name.newWithoutValidation(this.givenName, this.familyName);

  /// named constructor is like a factory method
  Name.ofGivenAndFamilyName(this.givenName, this.familyName) {
    _validate();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Name &&
          runtimeType == other.runtimeType &&
          givenName == other.givenName &&
          familyName == other.familyName;

  @override
  int get hashCode => givenName.hashCode ^ familyName.hashCode;

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

  Id.generate() : id = Uuid().v4();

  const Id.newWithoutValidation(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Id && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// value object for an EmailAddress
class EmailAddress {
  final String email;
  final bool isConfirmed;

  const EmailAddress._(this.email, this.isConfirmed);

  const EmailAddress.of(this.email) : isConfirmed = false;

  EmailAddress confirm() => EmailAddress._(email, true);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAddress &&
          runtimeType == other.runtimeType &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;

  @override
  String toString() {
    return '{email: $email, isConfirmed: $isConfirmed}';
  }
}

/// value object for an Address
class Address {
  final String street;
  final String houseNumber;
  final String city;
  final String postalCode;
  final String countryCode;

  const Address.of(this.street, this.houseNumber, this.city, this.postalCode,
      this.countryCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          street == other.street &&
          houseNumber == other.houseNumber &&
          city == other.city &&
          postalCode == other.postalCode &&
          countryCode == other.countryCode;

  @override
  int get hashCode =>
      street.hashCode ^
      houseNumber.hashCode ^
      city.hashCode ^
      postalCode.hashCode ^
      countryCode.hashCode;
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
    for (DomainEvent e in events) {
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

  void changeAddress(Address address) {
    if (_homeAddress == address) {
      return;
    }
    DomainEvent e = null;
    if (_homeAddress == null) {
      e = AddressAdded.of(address);
    } else {
      e = AddressChanged.of(address);
    }
    _recordEvent(e);
    _apply(e);
  }

  void changeName(Name name) {
    if (name == _name) {
      return;
    }
    final DomainEvent<NameChanged> e = NameChanged.of(name);
    _recordEvent(e);
    _apply(e);
  }

  void _recordEvent(DomainEvent e) => _recordedEvents.add(e);

  void _apply(DomainEvent e) {
    if (e.payload is PersonRegistered) {
      _whenPersonRegistered(e.payload);
    }
    if (e.payload is EmailAddressConfirmed) {
      _whenEmailAddressConfirmed(e.payload);
    }
    if (e.payload is AddressAdded) {
      _whenAddressAdded(e.payload);
    }
    if (e.payload is AddressChanged) {
      _whenAddressChanged(e.payload);
    }
    if (e.payload is NameChanged) {
      _whenNameChanged(e.payload);
    }
  }

  void _whenPersonRegistered(PersonRegistered e) {
    _id = e.id;
    _name = e.name;
    _workMail = e.email;
  }

  void _whenEmailAddressConfirmed(EmailAddressConfirmed e) {
    _workMail = _workMail.confirm();
  }

  void _whenAddressAdded(AddressAdded e) {
    _homeAddress = e.address;
  }

  void _whenAddressChanged(AddressChanged e) {
    _homeAddress = e.address;
  }

  void _whenNameChanged(NameChanged e) {
    _name = e.name;
  }
}
