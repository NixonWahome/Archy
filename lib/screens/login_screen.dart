import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/archy_context.dart';
import '../core/design/archy_theme.dart';
import '../core/design/archy_tokens.dart';
import '../core/design/archy_widgets.dart';
import '../core/services/auth_service.dart';
import 'widgets/auth_hero.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  const LoginScreen({super.key, this.isDarkMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('user-not-found')
            ? 'No account found with this email'
            : e.toString().contains('wrong-password') ||
                    e.toString().contains('invalid-credential')
                ? 'Incorrect email or password'
                : 'Login failed. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.archy;
    return Scaffold(
      backgroundColor: c.paper,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHero(c: c, height: 230),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text('Welcome back', style: ArchyTheme.serif(c, size: 30)),
                const SizedBox(height: 6),
                Text('Sign in to pick up where you left off.',
                    style: ArchyTheme.sans(c, size: 14, color: c.ink2)),
                const SizedBox(height: 32),
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password is required' : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(c: c, message: _errorMessage!),
                ],
                const SizedBox(height: 28),
                ArchyButton(
                  c: c,
                  label: 'Log in',
                  icon: Icons.arrow_forward,
                  full: true,
                  busy: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: ArchyTheme.sans(c, size: 14, color: c.ink2),
                        children: [
                          const TextSpan(text: 'New to Archy?  '),
                          TextSpan(
                            text: 'Create account',
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

class _ErrorBanner extends StatelessWidget {
  final ArchyColors c;
  final String message;
  const _ErrorBanner({required this.c, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Text(message,
                style: ArchyTheme.sans(c, size: 13, color: c.clayDeep)),
          ),
        ],
      ),
    );
  }
}
