import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut_app/features/auth/presentation/providers/auth_session_notifier.dart';
import 'package:jdonut_app/features/auth/data/services/fake_auth_service.dart';
import 'package:jdonut_app/features/auth/presentation/providers/providers.dart';
import 'package:jdonut_app/features/auth/domain/validators/otp_validator.dart';
import 'package:jdonut_app/core/utils/app_logger.dart';

const int kMaxOtpAttempts = 3;
const int kResendSeconds = 5 * 60;

enum OtpStatus { idle, checking, verified, locked }

class VerifyOtpState {
  const VerifyOtpState({
    this.status = OtpStatus.idle,
    this.error,
    this.attemptsLeft = kMaxOtpAttempts,
    this.resendIn = kResendSeconds,
    this.shakeCount = 0,
  });

  final OtpStatus status;
  final String? error;
  final int attemptsLeft;
  final int resendIn;
  final int shakeCount;

  bool get locked => status == OtpStatus.locked;
  bool get checking => status == OtpStatus.checking;
  bool get canResend => (resendIn == 0 || locked) && !checking;

  VerifyOtpState copyWith({
    OtpStatus? status,
    String? error,
    bool clearError = false,
    int? attemptsLeft,
    int? resendIn,
    int? shakeCount,
  }) {
    return VerifyOtpState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      resendIn: resendIn ?? this.resendIn,
      shakeCount: shakeCount ?? this.shakeCount,
    );
  }
}

String _formatMessage(OtpFailure f) => switch (f) {
  OtpFailure.empty => 'Enter the code we sent you.',
  OtpFailure.nonDigit => 'The code can only contain digits.',
  OtpFailure.wrongLength => 'The code must be $kOtpLength digits.',
};

// Provider arguments
typedef VerifyOtpArgs = ({String phone, bool isNewUser});

final verifyOtpProvider = NotifierProvider.autoDispose
    .family<VerifyOtpNotifier, VerifyOtpState, VerifyOtpArgs>(
      VerifyOtpNotifier.new,
    );

class VerifyOtpNotifier extends Notifier<VerifyOtpState> {
  VerifyOtpNotifier(this.args);

  final VerifyOtpArgs args;

  String get phone => args.phone;

  Timer? _timer;

  AuthService get _auth => ref.read(authServiceProvider);

  @override
  VerifyOtpState build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();

    return const VerifyOtpState();
  }

  Future<void> submit(String text) async {
    if (state.status != OtpStatus.idle) return;

    final result = validateOtpFormat(text);
    final code = result.value;

    if (!result.isValid || code == null) {
      state = state.copyWith(error: _formatMessage(result.failure!));
      return;
    }

    state = state.copyWith(status: OtpStatus.checking, clearError: true);

    try {
      final tokens = await _auth.verifyOtp(phone, code);

      if (!ref.mounted) return;

      logger.w('OTP verified successfully');

      // Save access token and refresh token.
      await ref
          .read(authSessionProvider.notifier)
          .signIn(tokens, isNewUser: args.isNewUser);

      if (!ref.mounted) return;

      state = state.copyWith(status: OtpStatus.verified);
    } on AuthException {
      if (!ref.mounted) return;

      final left = state.attemptsLeft - 1;
      final locked = left <= 0;

      state = state.copyWith(
        status: locked ? OtpStatus.locked : OtpStatus.idle,
        attemptsLeft: left,
        shakeCount: state.shakeCount + 1,
        error: locked
            ? 'Too many wrong attempts. Tap “Resend code” to get a new one.'
            : 'Wrong code. $left ${left == 1 ? 'attempt' : 'attempts'} left.',
      );
    } catch (_) {
      if (!ref.mounted) return;

      state = state.copyWith(
        status: OtpStatus.idle,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  void clearError() {
    if (state.error != null && state.status == OtpStatus.idle) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<bool> resend() async {
    if (!state.canResend) return false;

    try {
      await _auth.sendOtp(phone);

      if (!ref.mounted) return false;

      state = const VerifyOtpState();
      _startTimer();

      return true;
    } on AuthException catch (e) {
      if (!ref.mounted) return false;

      state = state.copyWith(error: e.message);
    } catch (_) {
      if (!ref.mounted) return false;

      state = state.copyWith(error: 'Could not send code. Try again.');
    }

    return false;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }

      if (state.resendIn <= 1) {
        timer.cancel();
        state = state.copyWith(resendIn: 0);
      } else {
        state = state.copyWith(resendIn: state.resendIn - 1);
      }
    });
  }
}
