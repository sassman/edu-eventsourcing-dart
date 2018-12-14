import 'package:event_sourcing_workshop/event_sourcing_workshop.dart';
import 'package:test/test.dart';

void main() {
  group('Name tests', () {
    Name name;

    setUp(() {
      name = Name.ofGivenAndFamilyName('Sven', 'Assmann');
    });

    test('givenName', () {
      expect(name.givenName, equals('Sven'));
    });

    test('familyName', () {
      expect(name.familyName, equals('Assmann'));
    });

    test('given invalid firstname throws', () {
      expect(() => Name.ofGivenAndFamilyName('', 'Assmann'),
          throwsA(TypeMatcher<GivenNameIsEmpty>()));
    });

    test('given invalid lastname throws', () {
      expect(() => Name.ofGivenAndFamilyName('Sven', ''),
          throwsA(TypeMatcher<FamilyNameIsEmpty>()));
    });

    test('given invalid firstname does not throw', () {
      expect(Name.newWithoutValidation('', 'Assmann').familyName,
          equals('Assmann'));
    });
  });

  group('Id', () {
    test('a new Id', () {
      var id = Id.generate();
      expect(id.id, contains('-'));
    });
  });

  group('EmailAdress', () {
    test('a one', () {
      expect(EmailAddress.of('sven.assmann@sixt.com').email, contains('@'));
    });
  });

  group('Adress', () {
    test('a full address', () {
      final work = Address.of('Zugspitzstraße', '1', 'Pullach', '91123', 'DE');
      expect(work.countryCode, contains('DE'));
      expect(work.street, contains('straße'));
      expect(work.houseNumber, contains('1'));
    });
  });

  group('Person', () {
    Person person;

    givenRegisteredPerson() {
      person = Person.register(
          Id.generate(),
          Name.ofGivenAndFamilyName('sven', 'assmann'),
          EmailAddress.of('sven.assmann@sixt.com'));
    }

    givenConfirmedPerson() {
      givenRegisteredPerson();
      person.confirmEmail();
    }

    givenPersonWithAddress() {
      givenConfirmedPerson();
      person.changeAddress(Address.of('zugspitzstraße', '1', 'Munich', '91283', 'DE'));
    }

    test('register a new Person', () {
      givenRegisteredPerson();
      expect(person, TypeMatcher<Person>());
      expect(person.recordedEvents.length, equals(1));
      expect(person.recordedEvents[0],
          TypeMatcher<DomainEvent<PersonRegistered>>());
      expect(person.recordedEvents[0].eventName, equals('PersonRegistered'));
    });

    test('confirm email address', () {
      givenRegisteredPerson();

      person.confirmEmail();
      expect(person.recordedEvents.length, equals(2));
      expect(person.recordedEvents[1],
          TypeMatcher<DomainEvent<EmailAddressConfirmed>>());
      expect(
          person.recordedEvents[1].eventName, equals('EmailAddressConfirmed'));

      person.confirmEmail();
      expect(person.recordedEvents.length, equals(2));
    });

    test('reconstitue a confirmed person', () {
      givenConfirmedPerson();

      var p = Person.reconstitute(person.recordedEvents);
      p.confirmEmail();
      expect(p.recordedEvents.isEmpty, isTrue);
    });

    test('adding an address', () {
      givenConfirmedPerson();

      person.changeAddress(Address.of('zugspitzstraße', '1', 'Munich', '91283', 'DE'));
      expect(person.recordedEvents.length, equals(3));
      expect(person.recordedEvents[2],
          TypeMatcher<DomainEvent<AddressAdded>>());
    });

    test('changing an address', () {
      givenPersonWithAddress();

      person.changeAddress(Address.of('Zugspitzstraße', '1', 'Pullach', '82049', 'DE'));
      expect(person.recordedEvents.length, equals(4));
      expect(person.recordedEvents[3],
          TypeMatcher<DomainEvent<AddressChanged>>());

      // change the address to the same one will not change anything
      person.changeAddress(Address.of('Zugspitzstraße', '1', 'Pullach', '82049', 'DE'));
      expect(person.recordedEvents.length, equals(4));
    });
  });
}