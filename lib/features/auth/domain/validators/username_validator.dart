import 'package:jdonut_app/features/auth/domain/validators/validator.dart';

enum NameFailure { required, containsDigits, invalidCharacters, tooLong }

const int kNameMaxLength = 50;

// Letters (any script, incl. Myanmar), combining marks (Myanmar vowel signs,
// tone marks, asat, etc.) and spaces. Digits are not part of this set.
final RegExp _allowedName = RegExp(r'^[\p{L}\p{M} ]+$', unicode: true);

// Any decimal digit in any script (covers ASCII 0-9 and Myanmar ၀-၉).
final RegExp _anyDigit = RegExp(r'\p{Nd}', unicode: true);

/// Validates a person's name.
///
/// Rules (checked in this order, on the trimmed value):
///  1. required (skipped when [required] is false and the value is blank)
///  2. no digits (any script)
///  3. only letters and spaces (Myanmar script included)
///  4. at most [kNameMaxLength] characters
///
/// On success the value is the trimmed name (empty string for a blank
/// optional name).
Validated<String, NameFailure> validateName(
  String raw, {
  bool required = true,
}) {
  final v = raw.trim();

  if (v.isEmpty) {
    return required
        ? const Validated.invalid(NameFailure.required)
        : const Validated.valid('');
  }
  if (_anyDigit.hasMatch(v)) {
    return const Validated.invalid(NameFailure.containsDigits);
  }
  if (!_allowedName.hasMatch(v)) {
    return const Validated.invalid(NameFailure.invalidCharacters);
  }
  if (v.runes.length > kNameMaxLength) {
    return const Validated.invalid(NameFailure.tooLong);
  }
  return Validated.valid(v);
}

/// First name: required.
Validated<String, NameFailure> validateFirstName(String raw) =>
    validateName(raw);

/// Last name: optional (many Myanmar names have no family name), but if
/// present it must follow the same rules.
Validated<String, NameFailure> validateLastName(String raw) =>
    validateName(raw, required: false);
