import 'package:jdonut_app/features/auth/domain/validators/validator.dart';

enum PhoneFailure { empty, invalidFormat }

const String kMyanmarCountryCode = '+95';

final RegExp _separators = RegExp(r'[\s-]');
final RegExp _myanmarMobile = RegExp(r'^9\d{7,9}$');

/// Validates the part of a Myanmar number typed after "+95".
///
/// Steps:
///  1. strip spaces and dashes
///  2. strip ONE leading 0
///  3. the result must be a 9 followed by 7 to 9 digits
///
/// On success the value is the national number without country code,
/// e.g. `09254135592` -> `9254135592`.
Validated<String, PhoneFailure> validateMyanmarPhone(String raw) {
  final cleaned = raw.replaceAll(_separators, '');
  if (cleaned.isEmpty) return const Validated.invalid(PhoneFailure.empty);

  final national = cleaned.startsWith('0') ? cleaned.substring(1) : cleaned;

  if (!_myanmarMobile.hasMatch(national)) {
    return const Validated.invalid(PhoneFailure.invalidFormat);
  }
  return Validated.valid(national);
}

/// `9254135592` -> `+959254135592`
String toE164(String nationalNumber) => '$kMyanmarCountryCode$nationalNumber';
