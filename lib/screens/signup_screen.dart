import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/archy_context.dart';
import '../core/design/archy_theme.dart';
import '../core/design/archy_tokens.dart';
import '../core/design/archy_widgets.dart';
import '../core/services/auth_service.dart';
import 'widgets/auth_hero.dart';

class SignupScreen extends StatefulWidget {
  final bool isDarkMode;
  const SignupScreen({super.key, this.isDarkMode = false});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'diaspora';
  bool _isLoading = false;
  bool _obscure = true;
  String? _errorMessage;

  static const _roles = [
    ('diaspora', 'Diaspora client', Icons.home_outlined),
    ('architect', 'Architect', Icons.architecture),
    ('developer', 'Developer', Icons.vpn_key_outlined),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final credential = await authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await authService.createUserDocument(
        credential.user!,
        _nameController.text.trim(),
        _selectedRole,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('email-already-in-use')
            ? 'Email already in use. Try logging in.'
            : 'Signup failed. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.archy;
    final roleLabel =
        _roles.firstWhere((r) => r.$1 == _selectedRole).$2;
    return Scaffold(
      backgroundColor: c.paper,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AuthHero(c: c, height: 190),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text('Create your account',
                    style: ArchyTheme.serif(c, size: 30)),
                const SizedBox(height: 6),
                Text(
                    'Build, fund and follow projects across Kenya — wherever you are.',
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
                          padding: EdgeInsets.only(
                              right: r == _roles.last ? 0 : 8),
                          child: _RoleButton(
                            c: c,
                            icon: r.$3,
                            label: r.$2,
                            selected: _selectedRole == r.$1,
                            onTap: () => setState(() => _selectedRole = r.$1),
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
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                ArchyField(
                  c: c,
                  label: 'Email',
                  hint: 'grace@email.com',
                  icon: Icons.alternate_email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$')
                        .hasMatch(v)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ArchyField(
                  c: c,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  controller: _passwordController,
                  trailing: TextButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    child: Text(_obscure ? 'SHOW' : 'HIDE',
                        style: ArchyTheme.mono(c, size: 10.5, color: c.ink3)),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'At least 6 characters'
                      : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.claySoft,
                      borderRadius: BorderRadius.circular(ArchySize.radiusSm),
                      border: Border.all(color: c.clay.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 18, color: c.clayDeep),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: ArchyTheme.sans(c,
                                  size: 13, color: c.clayDeep)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                ArchyButton(
                  c: c,
                  label: 'Create $roleLabel account',
                  icon: Icons.arrow_forward,
                  full: true,
                  busy: _isLoading,
                  onPressed: _signup,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: ArchyTheme.sans(c, size: 14, color: c.ink2),
                        children: [
                          const TextSpan(text: 'Already have an account?  '),
                          TextSpan(
                            text: 'Log in',
                            style: ArchyTheme.sans(c,
                                size: 14,
                                weight: FontWeight.w600,
                                color: c.clay),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final ArchyColors c;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
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
      borderRadius: BorderRadius.circular(ArchySize.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? c.claySoft : c.paper2,
          borderRadius: BorderRadius.circular(ArchySize.radiusSm),
          border: Border.all(color: selected ? c.clay : c.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: selected ? c.clayDeep : c.ink2),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: ArchyTheme.sans(c,
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: selected ? c.clayDeep : c.ink2),
            ),
          ],
        ),
      ),
    );
  }
}
