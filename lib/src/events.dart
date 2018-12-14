import 'models.dart';

class DomainEvent<T> {
  String get eventName => payload.runtimeType.toString();
  final T payload;

  DomainEvent(this.payload);
}

class PersonRegistered {
  final Id id;
  final Name name;
  final EmailAddress email;

  PersonRegistered._(this.id, this.name, this.email);

  static of(Id id, Name name, EmailAddress email) {
    return DomainEvent(PersonRegistered._(id, name, email));
  }

  dynamic serialize() {
    // TODO hide the value objects in the serialization of the event
  }
}

class EmailAddressConfirmed {
  final Id id;

  EmailAddressConfirmed._(this.id);

  static of(Id id) {
    return DomainEvent(EmailAddressConfirmed._(id));
  }
}