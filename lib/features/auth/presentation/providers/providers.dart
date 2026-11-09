import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut_app/features/auth/data/services/fake_auth_service.dart';

final authServiceProvider = Provider<AuthService>((_) => FakeAuthService());
