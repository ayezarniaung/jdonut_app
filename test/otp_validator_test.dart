// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut_app/features/auth/domain/validators/otp_validator.dart';

void main() {
  group('validateOtpFormat', () {
    test('empty -> empty', () {
      expect(validateOtpFormat('').failure, OtpFailure.empty);
    });

    test('6 digits is valid', () {
      final r = validateOtpFormat('123456');
      expect(r.isValid, isTrue);
      expect(r.value, '123456');
    });

    test('leading zeros are kept', () {
      expect(validateOtpFormat('000123').value, '000123');
    });

    test('5 digits -> wrongLength', () {
      expect(validateOtpFormat('12345').failure, OtpFailure.wrongLength);
    });

    test('7 digits -> wrongLength', () {
      expect(validateOtpFormat('1234567').failure, OtpFailure.wrongLength);
    });

    test('letters -> nonDigit', () {
      expect(validateOtpFormat('12a456').failure, OtpFailure.nonDigit);
    });

    test('spaces -> nonDigit', () {
      expect(validateOtpFormat('123 56').failure, OtpFailure.nonDigit);
    });

    test('Myanmar digits are not accepted -> nonDigit', () {
      expect(validateOtpFormat('၁၂၃၄၅၆').failure, OtpFailure.nonDigit);
    });

    test('custom length is respected', () {
      expect(validateOtpFormat('1234', length: 4).isValid, isTrue);
      expect(
        validateOtpFormat('123456', length: 4).failure,
        OtpFailure.wrongLength,
      );
    });
  });
}
