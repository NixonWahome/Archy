import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/archy_context.dart';
import '../core/design/archy_theme.dart';
import '../core/design/archy_widgets.dart';
import '../core/services/auth_service.dart';

/// Shown when a user is authenticated but has no Firestore profile document
/// (e.g. account created on an older build, or the profile write was interrupted).
/// Writing the profile here un-sticks the login loop instead of bouncing back.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  String _role = 'diaspora';
  bool _saving = false;

  static const _roles = [
    ('diaspora', 'Diaspora client', Icons.home_outlined),
    ('architect', 'Architect', Icons.architecture),
    ('developer', 'Developer', Icons.vpn_key_outlined),
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    // Prefill the name from the email handle if we have nothing else.
    final email = user?.email ?? '';
    if (email.contains('@')) _nameController.text = email.split('@').first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await auth.createUserDocument(
        user,
        _nameController.text.trim().isEmpty
            ? 'User'
            : _nameController.text.trim(),
        _role,
      );
      // AuthWrapper rebuilds off the same stream; nudge it.
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.archy;
    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        backgroundColor: c.paper,
        title: const Text('Finish setting up'),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthService>().signOut(),
            child: Text('Sign out',
                style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome to Archy', style: ArchyTheme.serif(c, size: 28)),
              const SizedBox(height: 6),
              Text(
                  "We just need a couple of details to finish your account.",
                  style: ArchyTheme.sans(c, size: 14, color: c.ink2)),
              const SizedBox(height: 26),
              Text('I AM A',
                  style: ArchyTheme.mono(c, size: 11, color: c.ink3)),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final r in _roles)
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.only(right: r == _roles.last ? 0 : 8),
                        child: _RoleBtn(
                          c: c,
                          icon: r.$3,
                          label: r.$2,
                          selected: _role == r.$1,
                          onTap: () => setState(() => _role = r.$1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              ArchyField(
                c: c,
                label: 'Full name',
                hint: 'Grace Wanjiru',
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 28),
              ArchyButton(
                c: c,
                label: 'Continue',
                icon: Icons.arrow_forward,
                full: true,
                busy: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBtn extends StatelessWidget {
  final dynamic c;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleBtn({
    required this.c,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? c.claySoft : c.paper2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? c.clay : c.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: selected ? c.clayDeep : c.ink2),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: ArchyTheme.sans(c,
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: selected ? c.clayDeep : c.ink2)),
          ],
        ),
      ),
    );
  }
}
