import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut_app/features/auth/presentation/providers/auth_session_notifier.dart';
import 'package:jdonut_app/features/auth/presentation/screens/dob_screen.dart';
import 'package:jdonut_app/features/auth/presentation/screens/onboading_screen.dart';
import 'package:jdonut_app/features/auth/presentation/screens/phone_number_screen.dart';
import 'package:jdonut_app/features/auth/presentation/screens/username_screen.dart';
import 'package:jdonut_app/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:jdonut_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:jdonut_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:jdonut_app/shared/navigations/bottom_nav_screen.dart';
import 'package:jdonut_app/core/router/routes.dart';

const String kProductPath = '/product';

String productLocation(String id) => '$kProductPath/${Uri.encodeComponent(id)}';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Register journey routes
final Set<String> _publicRoutes = {
  Routes.onboadingScreen,
  Routes.phoneScreen,
  Routes.verifyOtpScreen,
  Routes.usernameScreen,
  Routes.dobScreen,
  Routes.welcomeScreen,
  Routes.bottomNavScreen,
};

// Login journey routes
final Set<String> _profileRoutes = {
  Routes.phoneScreen,
  Routes.verifyOtpScreen,
  Routes.welcomeScreen,
  Routes.bottomNavScreen,
};

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(ProviderContainer container) {
    _subscription = container.listen<AuthSessionState>(authSessionProvider, (
      previous,
      next,
    ) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthSessionState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

GoRouter createAppRouter(ProviderContainer container) {
  final refreshListenable = AuthRouterRefresh(container);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.onboadingScreen,
    refreshListenable: refreshListenable,

    redirect: (context, state) {
      final auth = container.read(authSessionProvider);
      final path = state.uri.path;

      final isProductRoute = path.startsWith('$kProductPath/');

      // Not authenticated
      if (!auth.isAuthenticated) {
        final allowedRoutes = {
          Routes.onboadingScreen,
          Routes.phoneScreen,
          Routes.verifyOtpScreen,
        };

        if (allowedRoutes.contains(path)) {
          return null;
        }

        return Routes.onboadingScreen;
      }

      // Authenticated: Register journey
      if (auth.isNewUser) {
        if (_publicRoutes.contains(path) &&
            path != Routes.onboadingScreen &&
            path != Routes.phoneScreen &&
            path != Routes.verifyOtpScreen) {
          return null;
        }

        if (isProductRoute) return null;

        return Routes.usernameScreen;
      }

      // Authenticated: Login / returning user journey
      if (_profileRoutes.contains(path)) {
        if (path == Routes.phoneScreen || path == Routes.verifyOtpScreen) {
          return Routes.bottomNavScreen;
        }

        return null;
      }

      if (isProductRoute) return null;

      return Routes.bottomNavScreen;
    },

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(child: Text('No route defined for ${state.uri}')),
      );
    },

    routes: [
      GoRoute(
        path: Routes.onboadingScreen,
        builder: (context, state) => const OnboadingScreen(),
      ),
      GoRoute(
        path: Routes.phoneScreen,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};

          return PhoneNumberScreen(isNewUser: args['isNewUser'] ?? false);
        },
      ),
      GoRoute(
        path: Routes.verifyOtpScreen,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};

          return VerifyOtpScreen(
            phoneNumber: args['phoneNumber'] ?? '',
            isNewUser: args['isNewUser'] ?? false,
          );
        },
      ),
      GoRoute(
        path: Routes.usernameScreen,
        builder: (context, state) => UsernameScreen(),
      ),
      GoRoute(
        path: Routes.dobScreen,
        builder: (context, state) => const DobScreen(),
      ),
      GoRoute(
        path: Routes.welcomeScreen,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.bottomNavScreen,
        builder: (context, state) => BottomNavScreen(),
      ),
      GoRoute(
        path: '$kProductPath/:id',
        name: 'product',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;

          return ProductDetailScreen(productId: productId);
        },
      ),
    ],
  );
}
