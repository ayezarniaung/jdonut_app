import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut_app/core/router/app_router.dart';
import 'package:jdonut_app/features/auth/presentation/providers/auth_session_notifier.dart';
import 'package:jdonut_app/features/home/presentation/providers/repository_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(authSessionProvider.notifier).restore();
  await container.read(productRepositoryProvider).seedProducts();
  await container.read(bannerRepositoryProvider).seedBanners();
  await container.read(shopRepositoryProvider).seedShops();
  final router = createAppRouter(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'J\'Donuts App',
      routerConfig: router,
    );
  }
}
