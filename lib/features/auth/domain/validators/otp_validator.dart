import 'package:jdonut_app/features/auth/domain/validators/validator.dart';

enum OtpFailure { empty, nonDigit, wrongLength }

const int kOtpLength = 6;

final RegExp _asciiDigitsOnly = RegExp(r'^[0-9]+$');

/// Format check only (is this a well-formed OTP?). Whether the code is
/// *correct* is decided by the backend.
Validated<String, OtpFailure> validateOtpFormat(
  String raw, {
  int length = kOtpLength,
}) {
  if (raw.isEmpty) return const Validated.invalid(OtpFailure.empty);
  if (!_asciiDigitsOnly.hasMatch(raw)) {
    return const Validated.invalid(OtpFailure.nonDigit);
  }
  if (raw.length != length) {
    return const Validated.invalid(OtpFailure.wrongLength);
  }
  return Validated.valid(raw);
}
