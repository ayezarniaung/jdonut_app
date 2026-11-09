// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut_app/features/auth/domain/validators/phone_validator.dart';

void main() {
  group('validateMyanmarPhone – empty', () {
    test('empty -> empty', () {
      expect(validateMyanmarPhone('').failure, PhoneFailure.empty);
    });

    test('only spaces and dashes -> empty', () {
      expect(validateMyanmarPhone(' - - ').failure, PhoneFailure.empty);
    });
  });

  group('validateMyanmarPhone – strips spaces and dashes', () {
    test('spaces are removed', () {
      expect(validateMyanmarPhone('9 254 135 592').value, '9254135592');
    });

    test('dashes are removed', () {
      expect(validateMyanmarPhone('9-254-135-592').value, '9254135592');
    });

    test('mixed spaces and dashes are removed', () {
      expect(validateMyanmarPhone('09 254-135 592').value, '9254135592');
    });

    test('leading/trailing spaces are removed', () {
      expect(validateMyanmarPhone('  9254135592  ').value, '9254135592');
    });
  });

  group('validateMyanmarPhone – leading zero', () {
    test('one leading 0 is stripped (spec example)', () {
      final r = validateMyanmarPhone('09254135592');
      expect(r.isValid, isTrue);
      expect(r.value, '9254135592');
      expect(toE164(r.value!), '+959254135592');
    });

    test('number without leading 0 is valid', () {
      expect(validateMyanmarPhone('9254135592').value, '9254135592');
    });

    test('only ONE leading 0 is stripped (00… is invalid)', () {
      expect(
        validateMyanmarPhone('009254135592').failure,
        PhoneFailure.invalidFormat,
      );
    });

    test('a 0 that is not leading is kept', () {
      expect(validateMyanmarPhone('90254135').value, '90254135');
    });
  });

  group('validateMyanmarPhone – must start with 9', () {
    test('starts with 1 -> invalidFormat', () {
      expect(
        validateMyanmarPhone('1254135592').failure,
        PhoneFailure.invalidFormat,
      );
    });

    test('starts with 8 -> invalidFormat', () {
      expect(
        validateMyanmarPhone('8254135592').failure,
        PhoneFailure.invalidFormat,
      );
    });

    test('just "0" -> invalidFormat', () {
      expect(validateMyanmarPhone('0').failure, PhoneFailure.invalidFormat);
    });
  });

  group('validateMyanmarPhone – 7 to 9 digits after the 9', () {
    test('6 digits after the 9 -> invalidFormat', () {
      expect(
        validateMyanmarPhone('9123456').failure,
        PhoneFailure.invalidFormat,
      );
    });

    test('7 digits after the 9 (8 total) is valid', () {
      expect(validateMyanmarPhone('91234567').isValid, isTrue);
    });

    test('8 digits after the 9 (9 total) is valid', () {
      expect(validateMyanmarPhone('912345678').isValid, isTrue);
    });

    test('9 digits after the 9 (10 total) is valid', () {
      expect(validateMyanmarPhone('9123456789').isValid, isTrue);
    });

    test('10 digits after the 9 (11 total) -> invalidFormat', () {
      expect(
        validateMyanmarPhone('91234567890').failure,
        PhoneFailure.invalidFormat,
      );
    });

    test('boundaries also hold with a leading 0', () {
      expect(
        validateMyanmarPhone('0912345').failure,
        PhoneFailure.invalidFormat,
      );
      expect(validateMyanmarPhone('091234567').isValid, isTrue);
      expect(validateMyanmarPhone('09123456789').isValid, isTrue);
      expect(
        validateMyanmarPhone('091234567890').failure,
        PhoneFailure.invalidFormat,
      );
    });
  });

  group('validateMyanmarPhone – only digits', () {
    test('letters -> invalidFormat', () {
      expect(
        validateMyanmarPhone('9abc4135592').failure,
        PhoneFailure.invalidFormat,
      );
    });

    test('plus sign -> invalidFormat', () {
      expect(
        validateMyanmarPhone('+9254135592').failure,
        PhoneFailure.invalidFormat,
      );
    });

    test('parentheses / dots -> invalidFormat', () {
      expect(
        validateMyanmarPhone('(9254)135.592').failure,
        PhoneFailure.invalidFormat,
      );
    });
  });

  group('toE164', () {
    test('prefixes the Myanmar country code', () {
      expect(toE164('9254135592'), '+959254135592');
    });
  });
}
