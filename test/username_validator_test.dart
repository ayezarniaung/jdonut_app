// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut_app/features/auth/domain/validators/username_validator.dart';

void main() {
  group('validateName – required', () {
    test('empty string -> required', () {
      expect(validateName('').failure, NameFailure.required);
    });

    test('only spaces -> required', () {
      expect(validateName('    ').failure, NameFailure.required);
    });

    test('optional + empty -> valid with empty value', () {
      final r = validateName('', required: false);
      expect(r.isValid, isTrue);
      expect(r.value, '');
    });

    test('optional + only spaces -> valid with empty value', () {
      final r = validateName('   ', required: false);
      expect(r.isValid, isTrue);
      expect(r.value, '');
    });
  });

  group('validateName – trimming', () {
    test('surrounding spaces are trimmed from the value', () {
      expect(validateName('  Aung  ').value, 'Aung');
    });

    test('length is measured after trimming (50 chars + padding is ok)', () {
      final r = validateName('  ${'a' * 50}  ');
      expect(r.isValid, isTrue);
      expect(r.value, 'a' * 50);
    });
  });

  group('validateName – length (1..50)', () {
    test('1 character is valid', () {
      expect(validateName('A').isValid, isTrue);
    });

    test('exactly 50 characters is valid', () {
      expect(validateName('a' * 50).isValid, isTrue);
    });

    test('51 characters -> tooLong', () {
      expect(validateName('a' * 51).failure, NameFailure.tooLong);
    });

    test('50 Myanmar characters is valid, 51 is tooLong', () {
      // က (U+1000) is a single Myanmar letter.
      expect(validateName('က' * 50).isValid, isTrue);
      expect(validateName('က' * 51).failure, NameFailure.tooLong);
    });
  });

  group('validateName – letters and spaces', () {
    test('Latin letters are valid', () {
      expect(validateName('Aung').isValid, isTrue);
    });

    test('spaces inside the name are valid', () {
      expect(validateName('Mary Jane').value, 'Mary Jane');
    });

    test('accented letters are valid', () {
      expect(validateName('José').isValid, isTrue);
    });

    test('underscore -> invalidCharacters', () {
      expect(validateName('John_').failure, NameFailure.invalidCharacters);
    });

    test('apostrophe -> invalidCharacters', () {
      expect(validateName("O'Brien").failure, NameFailure.invalidCharacters);
    });

    test('hyphen -> invalidCharacters', () {
      expect(validateName('Anne-Marie').failure, NameFailure.invalidCharacters);
    });

    test('punctuation and symbols -> invalidCharacters', () {
      expect(validateName('Aung!').failure, NameFailure.invalidCharacters);
      expect(validateName('Aung@').failure, NameFailure.invalidCharacters);
    });

    test('emoji -> invalidCharacters', () {
      expect(validateName('Aung 😀').failure, NameFailure.invalidCharacters);
    });
  });

  group('validateName – Myanmar script', () {
    test('Myanmar word with combining marks is valid', () {
      expect(validateName('မြန်မာ').isValid, isTrue);
    });

    test('Myanmar name with a space is valid', () {
      expect(validateName('မောင် မောင်').isValid, isTrue);
    });

    test('Myanmar and Latin can be mixed', () {
      expect(validateName('ကို Aung').isValid, isTrue);
    });

    test('Myanmar punctuation sign (၊) -> invalidCharacters', () {
      expect(validateName('မောင်၊').failure, NameFailure.invalidCharacters);
    });
  });

  group('validateName – no digits', () {
    test('ASCII digit -> containsDigits', () {
      expect(validateName('Aung2').failure, NameFailure.containsDigits);
    });

    test('only digits -> containsDigits', () {
      expect(validateName('12345').failure, NameFailure.containsDigits);
    });

    test('Myanmar digits (၁၂) -> containsDigits', () {
      expect(validateName('ကိုမောင်၁၂').failure, NameFailure.containsDigits);
    });

    test('digits are reported before other invalid characters', () {
      expect(validateName('a_1').failure, NameFailure.containsDigits);
    });
  });

  group('validateFirstName / validateLastName', () {
    test('first name is required', () {
      expect(validateFirstName('').failure, NameFailure.required);
    });

    test('last name is optional', () {
      final r = validateLastName('');
      expect(r.isValid, isTrue);
      expect(r.value, '');
    });

    test('last name still follows the character rules when provided', () {
      expect(validateLastName('Smith2').failure, NameFailure.containsDigits);
      expect(validateLastName('Smith_').failure, NameFailure.invalidCharacters);
      expect(validateLastName('a' * 51).failure, NameFailure.tooLong);
    });

    test('last name accepts Myanmar script', () {
      expect(validateLastName('မြင့်').isValid, isTrue);
    });
  });
}
