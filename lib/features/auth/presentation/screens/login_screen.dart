import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/network/supabase_connection_provider.dart';
import '../../../../core/utils/validators.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authControllerProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      ref.invalidate(currentUserProvider);
      if (mounted) context.go(RouteNames.splash);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthPageScaffold(
      title: AppConstants.appName,
      child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue learning',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (!Env.isConfigured) ...[
                    const SizedBox(height: 16),
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.warning_amber),
                        title: Text('Supabase not configured'),
                        subtitle: Text(
                          'Update .env with your Supabase URL and anon key.',
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    _ConnectionBanner(),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                        Validators.requiredField(value, fieldName: 'Password'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(RouteNames.forgotPassword),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.push(RouteNames.register),
                    child: const Text('Create student account'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ConnectionBanner extends ConsumerWidget {
  const _ConnectionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(supabaseConnectionProvider);

    return connection.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Card(
        child: ListTile(
          leading: Icon(Icons.cloud_off, color: Colors.orange),
          title: Text('Could not verify connection'),
          subtitle: Text('Run migrations in Supabase SQL Editor'),
        ),
      ),
      data: (connected) => Card(
        color: connected ? Colors.green.shade50 : Colors.orange.shade50,
        child: ListTile(
          leading: Icon(
            connected ? Icons.cloud_done : Icons.cloud_off,
            color: connected ? Colors.green : Colors.orange,
          ),
          title: Text(connected ? 'Connected to Supabase' : 'Database not ready'),
          subtitle: Text(
            connected
                ? 'Backend is configured and reachable'
                : 'Apply migrations — see docs/05_SUPABASE_SETUP.md',
          ),
        ),
      ),
    );
  }
}
