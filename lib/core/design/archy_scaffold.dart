import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme_controller.dart';
import 'archy_context.dart';
import 'archy_theme.dart';
import 'archy_tokens.dart';

/// A consistent dashboard chrome shared by all three roles, so the app reads as
/// one design: editorial app bar (serif title + mono subtitle, theme + sign-out
/// actions) and a flat bottom tab bar with the clay accent.
class ArchyDashboardScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ArchyTab> tabs;
  final int index;
  final ValueChanged<int> onTabChanged;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget> extraActions;

  const ArchyDashboardScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.tabs,
    required this.index,
    required this.onTabChanged,
    required this.body,
    this.floatingActionButton,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = context.archy;
    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        backgroundColor: c.paper,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: ArchyTheme.serif(c, size: 22)),
            if (subtitle != null)
              Text(subtitle!.toUpperCase(),
                  style: ArchyTheme.mono(c, size: 10, color: c.ink3)),
          ],
        ),
        actions: [
          ...extraActions,
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(c.isDark ? Icons.light_mode : Icons.dark_mode),
            color: c.ink2,
            onPressed: () => context.read<ThemeController>().toggle(),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            color: c.ink2,
            onPressed: () => context.read<AuthService>().signOut(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _ArchyTabBar(
        c: c,
        tabs: tabs,
        index: index,
        onChanged: onTabChanged,
      ),
    );
  }
}

class ArchyTab {
  final IconData icon;
  final String label;
  const ArchyTab(this.icon, this.label);
}

class _ArchyTabBar extends StatelessWidget {
  final ArchyColors c;
  final List<ArchyTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  const _ArchyTabBar({
    required this.c,
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.paper2,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (int i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tabs[i].icon,
                            size: 23,
                            color: i == index ? c.clay : c.ink3),
                        const SizedBox(height: 3),
                        Text(
                          tabs[i].label,
                          style: ArchyTheme.sans(c,
                              size: 11,
                              weight:
                                  i == index ? FontWeight.w600 : FontWeight.w400,
                              color: i == index ? c.clay : c.ink3),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
