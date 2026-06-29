import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/firebase/firebase_options.dart';
import 'core/services/auth_service.dart';
import 'core/services/database_service.dart';
import 'core/services/session_service.dart';
import 'core/design/archy_theme.dart';
import 'core/design/archy_tokens.dart';
import 'core/theme_controller.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ArchyApp());
}

class ArchyApp extends StatelessWidget {
  const ArchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (context) => ThemeController(),
        ),
        Provider<AuthService>(create: (context) => AuthService()),
        Provider<DatabaseService>(create: (context) => DatabaseService()),
        Provider<SessionService>(create: (context) => SessionService()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Archy',
            debugShowCheckedModeBanner: false,
            theme: ArchyTheme.build(ArchyColors.light),
            darkTheme: ArchyTheme.build(ArchyColors.dark),
            themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(isDarkMode: theme.isDark),
          );
        },
      ),
    );
  }
}
