import 'package:flutter/material.dart';

import '../../core/design/archy_theme.dart';
import '../../core/design/archy_tokens.dart';

/// Full-width architectural hero banner for the auth screens.
/// Shows assets/images/auth_hero.jpg; if that asset is missing it falls back to
/// a clay→blueprint gradient so the screen still looks intentional.
class AuthHero extends StatelessWidget {
  final ArchyColors c;
  final double height;

  const AuthHero({super.key, required this.c, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/auth_hero.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _GradientFallback(c: c),
          ),
          // Scrim so the brandmark stays readable over any photo.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 18,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: Text('A',
                      style: ArchyTheme.serif(c,
                          size: 20,
                          weight: FontWeight.w600,
                          color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Text('Archy',
                    style: ArchyTheme.serif(c,
                        size: 26, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientFallback extends StatelessWidget {
  final ArchyColors c;
  const _GradientFallback({required this.c});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.clay, c.clayDeep, c.blueprint],
        ),
      ),
      child: Center(
        child: Icon(Icons.architecture,
            size: 90, color: Colors.white.withValues(alpha: 0.25)),
      ),
    );
  }
}
