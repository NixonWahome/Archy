import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme_controller.dart';
import 'architect/architect_dashboard.dart';
import 'diaspora/diaspora_dashboard.dart';
import 'developer/developer_dashboard.dart';
import 'complete_profile_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDark = context.watch<ThemeController>().isDark;

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // Signed in. Load the Firestore profile to pick the right dashboard.
          // Keyed by uid so it re-fetches after a profile is created/recovered.
          return FutureBuilder<UserModel?>(
            key: ValueKey(snapshot.data!.uid),
            future: authService.getUserData(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Profile read failed (network/rules) — show a retry instead of
              // silently bouncing back to the login screen (the "freeze").
              if (userSnapshot.hasError) {
                return _RetryScaffold(
                  message: 'Could not load your profile.',
                  onRetry: () => (context as Element).markNeedsBuild(),
                  onSignOut: authService.signOut,
                );
              }

              final user = userSnapshot.data;
              if (user != null) {
                return _routeToRoleDashboard(user.role, isDark);
              }

              // Authenticated but NO profile document exists — recover by letting
              // them complete their profile, rather than looping to login.
              return const CompleteProfileScreen();
            },
          );
        }

        return LoginScreen(isDarkMode: isDark);
      },
    );
  }

  Widget _routeToRoleDashboard(String role, bool isDarkMode) {
    switch (role.toLowerCase()) {
      case 'architect':
        return ArchitectDashboard(isDarkMode: isDarkMode);
      case 'diaspora':
        return DiasporaDashboard(isDarkMode: isDarkMode);
      case 'developer':
        return DeveloperDashboard(isDarkMode: isDarkMode);
      default:
        // Unknown role on the profile — let them re-pick instead of dead-ending.
        return const CompleteProfileScreen();
    }
  }
}

class _RetryScaffold extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  const _RetryScaffold({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
              TextButton(onPressed: onSignOut, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }
}
