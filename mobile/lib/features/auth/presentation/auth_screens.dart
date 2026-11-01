import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../../shared/widgets/app_components.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        await ref.read(cloudProgressServiceProvider).prepareForAccount();
        await ref.read(cloudProgressServiceProvider).syncFromCloud();
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();
      if (user != null && mounted) {
        await ref.read(cloudProgressServiceProvider).prepareForAccount();
        await ref.read(cloudProgressServiceProvider).syncFromCloud();
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = ref.watch(preferencesProvider).language == AppLanguage.urdu;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          tooltip: isUrdu ? 'واپس' : 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isUrdu ? 'لاگ ان کریں' : 'Log in'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          const Center(child: AppLogo(height: 72)),
          const SizedBox(height: AppSpacing.large),
          if (_errorMessage != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: isUrdu ? 'ای میل' : 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: isUrdu ? 'پاس ورڈ' : 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(isUrdu ? 'لاگ ان' : 'Log in'),
          ),
          const SizedBox(height: AppSpacing.medium),
          OutlinedButton.icon(
            onPressed: _loading ? null : _googleLogin,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: Text(isUrdu ? 'گوگل سے سائن ان کریں' : 'Sign in with Google'),
          ),
          const SizedBox(height: AppSpacing.large),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isUrdu ? 'اکاؤنٹ نہیں ہے؟' : "Don't have an account?"),
              TextButton(
                onPressed: () => context.push('/auth/register'),
                child: Text(isUrdu ? 'رجستر کریں' : 'Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      await authService.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        // Email/password registration signs the user in immediately. Activate
        // the cloud-only progress session just like the login and Google flows.
        final cloudProgress = ref.read(cloudProgressServiceProvider);
        await cloudProgress.prepareForAccount();
        await cloudProgress.syncFromCloud();
        if (mounted) context.go('/profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleRegister() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();
      if (user != null && mounted) {
        await ref.read(cloudProgressServiceProvider).prepareForAccount();
        await ref.read(cloudProgressServiceProvider).syncFromCloud();
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = ref.watch(preferencesProvider).language == AppLanguage.urdu;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          tooltip: isUrdu ? 'واپس' : 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isUrdu ? 'نیا اکاؤنٹ بنائیں' : 'Create account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          const Center(child: AppLogo(height: 72)),
          const SizedBox(height: AppSpacing.large),
          if (_errorMessage != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: isUrdu ? 'ای میل' : 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: isUrdu ? 'پاس ورڈ (کم از کم 6 حروف)' : 'Password (min 6 chars)',
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(isUrdu ? 'رجستر کریں' : 'Register'),
          ),
          const SizedBox(height: AppSpacing.medium),
          OutlinedButton.icon(
            onPressed: _loading ? null : _googleRegister,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: Text(
              isUrdu ? 'گوگل سے سائن ان کریں' : 'Sign in with Google',
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isUrdu ? 'پہلے سے اکاؤنٹ ہے؟' : 'Already have an account?'),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(isUrdu ? 'لاگ ان' : 'Log in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
