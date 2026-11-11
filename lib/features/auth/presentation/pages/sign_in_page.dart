import 'package:chatpilot_app/app/router/app_routes.dart';
import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/features/auth/domain/auth_exception.dart';
import 'package:chatpilot_app/features/auth/domain/auth_validators.dart';
import 'package:chatpilot_app/features/auth/presentation/auth_notifier.dart';
import 'package:chatpilot_app/l10n/l10n_ext.dart';
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

  String? _emailMessage(AuthEmailIssue? issue) {
    final l10n = context.l10n;
    return switch (issue) {
      AuthEmailIssue.empty => l10n.enterEmail,
      AuthEmailIssue.invalid => l10n.enterValidEmail,
      null => null,
    };
  }

  String? _passwordMessage(AuthPasswordIssue? issue) {
    final l10n = context.l10n;
    return switch (issue) {
      AuthPasswordIssue.empty => l10n.enterPassword,
      AuthPasswordIssue.tooShort => l10n.passwordTooShort,
      null => null,
    };
  }

  Future<void> _submit() async {
    final emailIssue = AuthValidators.emailIssue(_email.text);
    final passwordIssue = AuthValidators.passwordIssue(_password.text);
    setState(() {
      _emailError = _emailMessage(emailIssue);
      _passwordError = _passwordMessage(passwordIssue);
      _formError = null;
    });
    if (emailIssue != null || passwordIssue != null) return;

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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.syncChatPilot,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.signInBody,
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
              labelText: l10n.email,
              errorText: _emailError,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.password,
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
            child: Text(_submitting ? l10n.signingIn : l10n.signIn),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.signUp),
            child: Text(l10n.signUp),
          ),
        ],
      ),
    );
  }
}
