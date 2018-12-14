import 'package:event_sourcing_workshop/event_sourcing_workshop.dart';
import 'package:test/test.dart';

void main() {
  group('PersonRegistered', () {
    test('new', () {
      var id = Id.generate();
      var name = Name.ofGivenAndFamilyName('sven', 'assmann');
      var email = EmailAddress.of('sven.assmann@sixt.com');
      DomainEvent<PersonRegistered> p = PersonRegistered.of(id, name, email);

      expect(p.payload.id, equals(id));
      expect(p.payload.name, equals(name));
      expect(p.payload.email, equals(email));
    });
  });
}
