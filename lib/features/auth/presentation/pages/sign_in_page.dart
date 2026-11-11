import 'package:chatpilot_app/app/router/app_routes.dart';
import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/features/auth/domain/auth_exception.dart';
import 'package:chatpilot_app/features/auth/domain/auth_validators.dart';
import 'package:chatpilot_app/features/auth/presentation/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _formError;
  var _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = AuthValidators.emailError(_email.text);
    final passwordError = AuthValidators.passwordError(_password.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authProvider.notifier).signIn(
            email: _email.text,
            password: _password.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.conversations);
    } on AuthException catch (error) {
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Sync ChatPilot',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sign in to sync conversations with Supabase. Without an account, chats stay on this device only.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.secondary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _emailError,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _passwordError,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_formError != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _formError!,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            key: const ValueKey('sign-in-submit'),
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Signing in…' : 'Sign in'),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.signUp),
            child: const Text('Create account'),
          ),
        ],
      ),
    );
  }
}
