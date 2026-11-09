import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jdonut_app/features/auth/data/models/auth_model.dart';
import 'package:jdonut_app/core/utils/app_logger.dart';

enum AuthStatus { loggedOut, loggedIn }

class AuthSessionState {
  final AuthStatus status;
  final bool isNewUser;

  const AuthSessionState({
    this.status = AuthStatus.loggedOut,
    this.isNewUser = false,
  });

  bool get isAuthenticated => status == AuthStatus.loggedIn;
}

const _kAccess = 'access_token';
const _kRefresh = 'refresh_token';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  AuthSessionState build() => const AuthSessionState();

  // Restore saved token when app starts.
  Future<void> restore() async {
    final access = await _storage.read(key: _kAccess);

    state = AuthSessionState(
      status: access != null && access.isNotEmpty
          ? AuthStatus.loggedIn
          : AuthStatus.loggedOut,
    );

    logger.w("restored auth state: ${state.status}");
  }

  // Save tokens and update authentication state.
  Future<void> signIn(AuthTokens tokens, {required bool isNewUser}) async {
    await _storage.write(key: _kAccess, value: tokens.accessToken);

    await _storage.write(key: _kRefresh, value: tokens.refreshToken);

    state = AuthSessionState(status: AuthStatus.loggedIn, isNewUser: isNewUser);

    logger.w("signed in state: ${state.status}");
    logger.w("isNewUser: ${state.isNewUser}");
  }

  Future<void> signOut() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);

    state = const AuthSessionState(
      status: AuthStatus.loggedOut,
      isNewUser: false,
    );
  }
}
