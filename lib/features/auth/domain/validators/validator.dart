/// Result of a pure validation: either a (normalized) [value] or a [failure].
///
/// The domain layer only reports *what* went wrong (an enum). Turning a
/// failure into user-facing text is the UI layer's job.
class Validated<T, F extends Enum> {
  final T? value;
  final F? failure;

  const Validated.valid(T this.value) : failure = null;
  const Validated.invalid(F this.failure) : value = null;

  bool get isValid => failure == null;

  @override
  String toString() => isValid ? 'Valid($value)' : 'Invalid($failure)';
}
