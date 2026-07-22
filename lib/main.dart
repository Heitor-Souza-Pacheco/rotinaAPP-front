import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'core/token_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/habitos_provider.dart';
import 'providers/perfil_provider.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/habito_service.dart';
import 'services/perfil_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  // Adiciona estas 3 linhas:
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  runApp(const RotinaApp());
}


class RotinaApp extends StatelessWidget {
  const RotinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Grafo de dependências.
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);

    final authProvider =
        AuthProvider(AuthService(apiClient, tokenStorage), tokenStorage)
          ..init();
    final habitosProvider = HabitosProvider(HabitoService(apiClient));
    final perfilProvider = PerfilProvider(PerfilService(apiClient));

    // Ao expirar a sessão, força logout.
    apiClient.onUnauthorized = authProvider.onSessionExpired;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: habitosProvider),
        ChangeNotifierProvider.value(value: perfilProvider),
      ],
      child: MaterialApp(
        title: 'RotinaApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        home: const AuthGate(),
      ),
    );
  }
}

/// Decide entre a tela de login e a área autenticada conforme o estado.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    final Widget child = switch (status) {
      AuthStatus.unknown => const _SplashView(),
      AuthStatus.authenticated => const HomeShell(),
      AuthStatus.unauthenticated => const LoginScreen(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(status),
        child: child,
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child:
                  const Icon(Icons.spa_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}
