// lib/_core/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// --- IMPORTAÇÕES DE OBJETOS E ENUMS ---
import 'package:zeropoint/objetos/UsuariosLogados.dart';
import 'package:zeropoint/objetos/user_summary.dart';
import 'package:zeropoint/objetos/dispositivo.dart';
import 'package:zeropoint/_core/enums/verification_type_enum.dart';

// --- IMPORTAÇÕES DE SERVIÇOS ---
import 'package:zeropoint/services/auth_service.dart';
import 'package:zeropoint/services/token_storage_service.dart';

// --- IMPORTAÇÕES DAS TELAS ---
import 'package:zeropoint/screens/MenuPage.dart';
import 'package:zeropoint/screens/auth_screen.dart';
import 'package:zeropoint/screens/verification_screen.dart';
import 'package:zeropoint/screens/user/forgot_password_screen.dart';
import 'package:zeropoint/screens/reset_password_screen.dart';
import 'package:zeropoint/screens/ameacas_screen.dart';
import 'package:zeropoint/screens/device_management_screen.dart';
import 'package:zeropoint/screens/generic_history_screen.dart';
import 'package:zeropoint/screens/user/user_list_screen.dart';
import 'package:zeropoint/screens/settings_screen.dart';
import 'package:zeropoint/screens/device_history_detail_screen.dart';
import 'package:zeropoint/screens/user/user_details_screen.dart';
import 'package:zeropoint/screens/report_detail_screen.dart';

class AppRouter {
  final TokenStorageService tokenStorage = TokenStorageService();

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: _redirectLogic,
    routes: [
      // --- ROTAS PÚBLICAS ---
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          if (token == null) return const AuthScreen();
          return ResetPasswordScreen(token: token);
        },
      ),
      // Rota de Verificação (Agora tratada como pública no redirect)
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final userProvider = Provider.of<UsuariosLogados>(context, listen: false);

          VerificationType verificationType;
          if (args['verificationType'] != null) {
            verificationType = args['verificationType'];
          } else {
            // Fallback inteligente
            if (!userProvider.emailVerificado && userProvider.id != 0) {
              verificationType = VerificationType.email;
            } else {
              verificationType = VerificationType.twoFactor;
            }
          }

          return VerificationScreen(
            verificationType: verificationType,
            email: args['email'] ?? userProvider.email,
            tempToken: args['tempToken'],
          );
        },
      ),

      // --- ROTAS PROTEGIDAS ---
      GoRoute(
        path: '/',
        builder: (context, state) => const MenuPage(),
      ),
      GoRoute(
        path: '/threats',
        builder: (context, state) => const AmeacasScreen(),
      ),
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DeviceManagementScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return GenericHistoryScreen(
            filterType: args['filterType'] ?? HistoryFilterType.threat,
            initialSelectedItemId: args['initialSelectedItemId'],
          );
        },
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // --- DETALHES ---
      GoRoute(
        path: '/devices/:id',
        builder: (context, state) {
          final dispositivo = state.extra as Dispositivo?;
          if (dispositivo == null) return const DeviceManagementScreen();
          return DeviceHistoryDetailScreen(dispositivo: dispositivo);
        },
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) {
          final user = state.extra as UserSummary?;
          if (user == null) return const UserListScreen();
          return UserDetailsScreen(user: user);
        },
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return ReportDetailScreen(detectionId: id);
        },
      ),
    ],
  );

  /// ==========================================================================
  /// LÓGICA CORRIGIDA DE REDIRECIONAMENTO
  /// ==========================================================================
  Future<String?> _redirectLogic(BuildContext context, GoRouterState state) async {
    final userProvider = Provider.of<UsuariosLogados>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final hasToken = await tokenStorage.hasToken();

    // 1. Identifica para onde o usuário está tentando ir
    final matched = state.matchedLocation;
    final isLoggingIn = matched == '/login';
    // AQUI ESTÁ A CORREÇÃO: Adicionamos '/verify' à lista de permissões
    final isVerifying = matched == '/verify';
    final isRecoveringPassword = matched == '/reset-password' || matched == '/forgot-password';

    // 2. Se NÃO tem token
    if (!hasToken) {
      // Se ele está tentando logar, verificar ou recuperar senha, DEIXA PASSAR.
      if (isLoggingIn || isVerifying || isRecoveringPassword) {
        return null;
      }
      // Qualquer outra rota (ex: /home), chuta para o login
      return '/login';
    }

    // 3. Tem token mas o Provider está vazio (Refresh da página)
    if (hasToken && userProvider.id == 0) {
      print("[AppRouter] Token encontrado, mas Provider vazio. Buscando dados...");
      final success = await authService.fetchAndSetUser(context);

      if (!success) {
        await authService.logout(context);
        return '/login';
      }
    }

    // 4. Se já está logado (Tem token E dados no provider)

    // Se tentar ir para login, manda para Home
    if (isLoggingIn) {
      return '/';
    }

    // Se o email ainda não foi verificado, força a tela de verificação
    // (A menos que ele já esteja nela)
    if (!userProvider.emailVerificado) {
      if (!isVerifying) {
        return '/verify';
      }
    }

    return null; // Segue o fluxo normal
  }
}