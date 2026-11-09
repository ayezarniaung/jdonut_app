import 'package:jdonut_app/features/auth/data/models/auth_model.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class AuthService {
  Future<void> sendOtp(String phoneNumber);
  Future<AuthTokens> verifyOtp(String phoneNumber, String otp);
}

class FakeAuthService implements AuthService {
  static const validOtp = '123456';
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await Future<void>.delayed(_delay);
    if (phoneNumber.trim().isEmpty) {
      throw AuthException('Phone number is required');
    }
  }

  @override
  Future<AuthTokens> verifyOtp(String phoneNumber, String otp) async {
    await Future<void>.delayed(_delay);
    if (otp != validOtp) {
      throw AuthException('Invalid OTP');
    }

    final response = <String, dynamic>{
      'success': true,
      'data': {
        'accessToken':
            'fake-access-token-${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'fake-refresh-token',
        'expiresIn': 3600,
      },
    };
    return AuthTokens.fromJson(response);
  }
}

final AuthService authService = FakeAuthService();
