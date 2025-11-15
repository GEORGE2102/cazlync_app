import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/validators.dart';
import '../controllers/auth_providers.dart';
import 'register_screen.dart';

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

  Future<void> _handleEmailLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  Future<void> _handleGoogleLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleFacebookLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithFacebook();
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
                final success = await ref
                    .read(authControllerProvider.notifier)
                    .sendPasswordResetEmail(emailController.text.trim());
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Password reset email sent! Check your inbox.'
                            : 'Failed to send reset email. Please try again.',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Show error message if any
    ref.listen(authControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/logo/cazlync_logo.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if logo not found
                      return Icon(
                        Icons.directions_car,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Buy & Sell Cars in Zambia',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: Validators.validateEmail,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: Validators.validatePassword,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 24),
                // Login button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleEmailLogin,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 8),
                // Forgot password link
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: authState.isLoading ? null : _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                // Google sign in
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 12),
                // Facebook sign in
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _handleFacebookLogin,
                  icon: const Icon(Icons.facebook, size: 24),
                  label: const Text('Continue with Facebook'),
                ),
                const SizedBox(height: 24),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                      child: const Text('Register'),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
