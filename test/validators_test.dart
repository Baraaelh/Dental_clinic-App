import 'package:flutter_test/flutter_test.dart';
import 'package:graduation/core/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    test('rejects empty and malformed emails', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('not-an-email'), isNotNull);
    });
    test('accepts a valid email', () {
      expect(Validators.validateEmail('patient@example.com'), isNull);
    });
  });

  group('Validators.validatePassword', () {
    test('requires length, an uppercase letter and a digit', () {
      expect(Validators.validatePassword('Ab1'), isNotNull);
      expect(Validators.validatePassword('abcdefg1'), isNotNull);
      expect(Validators.validatePassword('Abcdefgh'), isNotNull);
      expect(Validators.validatePassword('Abcdefg1'), isNull);
    });
  });

  group('Validators.validatePhone', () {
    test('accepts international numbers', () {
      expect(Validators.validatePhone('+966500000000'), isNull);
      expect(Validators.validatePhone('12ab'), isNotNull);
    });
  });

  group('Validators.validateComment', () {
    test('enforces the same 10..1000 length the Firestore rules allow', () {
      expect(Validators.validateComment('short'), isNotNull);
      expect(Validators.validateComment('a' * 10), isNull);
      expect(Validators.validateComment('a' * 1001), isNotNull);
    });
  });
}
