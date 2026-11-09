// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut_app/features/auth/domain/validators/dob_validator.dart';

void main() {
  final now = DateTime(2026, 11, 8, 15, 30);

  Validated0 check(int? y, int? m, int? d, {int minYear = kMinBirthYear}) =>
      Validated0(
        validateDateOfBirth(
          year: y,
          month: m,
          day: d,
          now: now,
          minYear: minYear,
        ),
      );

  group('validateDateOfBirth – incomplete', () {
    test('missing year', () {
      expect(check(null, 5, 1).failure, DobFailure.incomplete);
    });

    test('missing month', () {
      expect(check(1980, null, 1).failure, DobFailure.incomplete);
    });

    test('missing day', () {
      expect(check(1980, 5, null).failure, DobFailure.incomplete);
    });

    test('all missing', () {
      expect(check(null, null, null).failure, DobFailure.incomplete);
    });
  });

  group('validateDateOfBirth – real calendar date', () {
    test('1 May 1980 is valid (screenshot example)', () {
      final r = validateDateOfBirth(year: 1980, month: 5, day: 1, now: now);
      expect(r.isValid, isTrue);
      expect(r.value, DateTime(1980, 5, 1));
    });

    test('30 February -> invalidDate', () {
      expect(check(1990, 2, 30).failure, DobFailure.invalidDate);
    });

    test('31 April -> invalidDate', () {
      expect(check(1990, 4, 31).failure, DobFailure.invalidDate);
    });

    test('29 February in a leap year is valid', () {
      expect(check(2000, 2, 29).isValid, isTrue);
    });

    test('29 February in a non-leap year -> invalidDate', () {
      expect(check(1900, 2, 29).failure, DobFailure.invalidDate);
      expect(check(2001, 2, 29).failure, DobFailure.invalidDate);
    });

    test('day 0 and day 32 -> invalidDate', () {
      expect(check(1990, 1, 0).failure, DobFailure.invalidDate);
      expect(check(1990, 1, 32).failure, DobFailure.invalidDate);
    });

    test('month 0 and month 13 -> invalidDate', () {
      expect(check(1990, 0, 1).failure, DobFailure.invalidDate);
      expect(check(1990, 13, 1).failure, DobFailure.invalidDate);
    });
  });

  group('validateDateOfBirth – minimum year', () {
    test('1 Jan 1900 is valid', () {
      expect(check(1900, 1, 1).isValid, isTrue);
    });

    test('31 Dec 1899 -> beforeMinYear', () {
      expect(check(1899, 12, 31).failure, DobFailure.beforeMinYear);
    });

    test('custom minYear is respected', () {
      expect(
        check(1950, 1, 1, minYear: 1960).failure,
        DobFailure.beforeMinYear,
      );
      expect(check(1960, 1, 1, minYear: 1960).isValid, isTrue);
    });
  });

  group('validateDateOfBirth – not in the future', () {
    test('today is valid (time of day is ignored)', () {
      expect(check(2026, 11, 8).isValid, isTrue);
    });

    test('yesterday is valid', () {
      expect(check(2026, 11, 7).isValid, isTrue);
    });

    test('tomorrow -> inFuture', () {
      expect(check(2026, 11, 9).failure, DobFailure.inFuture);
    });

    test('later this year -> inFuture', () {
      expect(check(2026, 12, 31).failure, DobFailure.inFuture);
    });

    test('next year -> inFuture', () {
      expect(check(2027, 1, 1).failure, DobFailure.inFuture);
    });
  });
}

/// Tiny adapter so tests can read `.failure` / `.isValid` tersely.
class Validated0 {
  final dynamic _r;
  Validated0(this._r);
  Object? get failure => _r.failure;
  bool get isValid => _r.isValid as bool;
}
