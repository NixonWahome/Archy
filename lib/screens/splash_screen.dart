import 'package:flutter/material.dart';

import '../core/design/archy_context.dart';
import '../core/design/archy_theme.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  const SplashScreen({super.key, this.isDarkMode = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthWrapper(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.archy;
    return Scaffold(
      backgroundColor: c.paper,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.clay,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text('A',
                      style: ArchyTheme.serif(c,
                          size: 52,
                          weight: FontWeight.w600,
                          color: Colors.white)),
                ),
                const SizedBox(height: 28),
                Text('Archy', style: ArchyTheme.serif(c, size: 40)),
                const SizedBox(height: 10),
                Text('Design together. Build anywhere.',
                    style: ArchyTheme.sans(c, size: 14, color: c.ink2)),
                const SizedBox(height: 44),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: c.clay.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
