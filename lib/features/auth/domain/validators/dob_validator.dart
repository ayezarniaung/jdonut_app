import 'package:jdonut_app/features/auth/domain/validators/validator.dart';

enum DobFailure { incomplete, invalidDate, beforeMinYear, inFuture }

const int kMinBirthYear = 1900;

/// Validates a date of birth built from separately chosen parts.
///
/// [now] is injected so the function stays pure and testable.
///
/// Rules (in order):
///  1. year, month and day must all be chosen
///  2. it must be a real calendar date (no 30 Feb, 31 Apr, 29 Feb in a
///     non-leap year)
///  3. year must be >= [minYear]
///  4. the date must not be after [now] (today is allowed)
Validated<DateTime, DobFailure> validateDateOfBirth({
  required int? year,
  required int? month,
  required int? day,
  required DateTime now,
  int minYear = kMinBirthYear,
}) {
  if (year == null || month == null || day == null) {
    return const Validated.invalid(DobFailure.incomplete);
  }

  final date = DateTime(year, month, day);
  // DateTime rolls invalid dates over (30 Feb -> 1/2 Mar), so compare parts.
  final isRealDate =
      date.year == year && date.month == month && date.day == day;
  if (!isRealDate) return const Validated.invalid(DobFailure.invalidDate);

  if (year < minYear) return const Validated.invalid(DobFailure.beforeMinYear);

  final today = DateTime(now.year, now.month, now.day);
  if (date.isAfter(today)) return const Validated.invalid(DobFailure.inFuture);

  return Validated.valid(date);
}
