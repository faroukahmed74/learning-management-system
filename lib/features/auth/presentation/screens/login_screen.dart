import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailNotConfirmed = false;
  bool _resendingVerification = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _emailNotConfirmed = false);

    try {
      await ref.read(authControllerProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      ref.invalidate(currentUserProvider);
      if (mounted) context.go(RouteNames.splash);
    } catch (error) {
      if (mounted) {
        setState(() {
          _emailNotConfirmed = _isEmailNotConfirmed(error);
        });
        showErrorSnackBar(context, error);
      }
    }
  }

  bool _isEmailNotConfirmed(Object error) {
    if (error is AuthException && error.code == 'email_not_confirmed') {
      return true;
    }
    return error.toString().toLowerCase().contains('email not confirmed');
  }

  Future<void> _resendVerification() async {
    final email = _emailController.text.trim();
    if (Validators.email(email, context.l10n) != null) return;

    setState(() => _resendingVerification = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .resendVerificationEmail(email);
      if (mounted) {
        showSuccessSnackBar(context, context.l10n.verificationEmailSent);
      }
    } catch (error) {
      if (mounted) showErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _resendingVerification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthPageScaffold(
      title: l10n.appName,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.appName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.signInSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (!Env.isConfigured) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.warning_amber),
                  title: Text(l10n.supabaseNotConfigured),
                  subtitle: Text(l10n.updateEnvFile),
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => Validators.email(v, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) =>
                  Validators.requiredField(value, l10n, fieldName: l10n.password),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => context.push(RouteNames.forgotPassword),
                child: Text(l10n.forgotPassword),
              ),
            ),
            if (_emailNotConfirmed) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.emailNotConfirmed,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed:
                            _resendingVerification ? null : _resendVerification,
                        child: _resendingVerification
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.resendVerification),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.signIn),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.push(RouteNames.register),
              child: Text(l10n.createAccount),
            ),
          ],
        ),
      ),
    );
  }
}
