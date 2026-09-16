import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../domain/auth_provider.dart';

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCreatingAccount = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _phoneController,
      _cityController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final notifier = ref.read(authProvider.notifier);
    final success = _isCreatingAccount
        ? await notifier.createEmailAccount(
            name: _nameController.text,
            phone: _phoneController.text,
            city: _cityController.text,
            email: _emailController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          )
        : await notifier.signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (!success) {
      if (state.error != null) _showMessage(state.error!);
      return;
    }
    if (_isCreatingAccount) {
      setState(() => _isCreatingAccount = false);
      _showMessage('Verification email sent. Verify your email, then sign in.');
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _googleSignIn() async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (success) {
      if (state.needsProfileCompletion) {
        final completed = await _completeGoogleProfile();
        if (!mounted || !completed) return;
      }
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (state.error != null) {
      _showMessage(state.error!);
    }
  }

  Future<bool> _completeGoogleProfile() async {
    final phoneController = TextEditingController();
    final cityController = TextEditingController();
    final values = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Complete your profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add these details so hospitals can coordinate care with you.'),
            const SizedBox(height: 16),
            TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact number', prefixText: '+91 ')),
            const SizedBox(height: 12),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context, [phoneController.text, cityController.text]), child: const Text('SAVE PROFILE')),
        ],
      ),
    );
    phoneController.dispose();
    cityController.dispose();
    if (values == null || !mounted) return false;
    final completed = await ref.read(authProvider.notifier).completeGoogleProfile(phone: values[0], city: values[1]);
    if (!completed && mounted) _showMessage(ref.read(authProvider).error ?? 'Please complete your profile.');
    return completed;
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _emailController.text);
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Use the email registered with ApnaCare. The link goes only to that inbox, so entering another email cannot change its password.'),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Account email'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('SEND LINK')),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.trim().isEmpty || !mounted) return;
    final success = await ref.read(authProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    final state = ref.read(authProvider);
    _showMessage(success ? 'Password reset link sent to your email.' : (state.error ?? 'Could not send reset link.'));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(_isCreatingAccount ? 'Create account' : 'Email access', style: AppTextStyles.heading3()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                child: const Icon(Icons.health_and_safety_outlined, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              Text(_isCreatingAccount ? 'Create your ApnaCare account' : 'Welcome back', style: AppTextStyles.heading1()),
              const SizedBox(height: 8),
              Text(
                _isCreatingAccount
                    ? 'Your contact number is stored for care coordination only. It is never used for SMS login.'
                    : 'Sign in with your verified email. No SMS or phone billing is required.',
                style: AppTextStyles.subHeader(),
              ),
              const SizedBox(height: 24),
              if (_isCreatingAccount) ...[
                _Field(controller: _nameController, label: 'Full name', icon: Icons.person_outline),
                const SizedBox(height: 12),
                _Field(controller: _phoneController, label: 'Contact number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, prefixText: '+91 '),
                const SizedBox(height: 12),
                _Field(controller: _cityController, label: 'City', icon: Icons.location_city_outlined),
                const SizedBox(height: 12),
              ],
              _Field(controller: _emailController, label: 'Email address', icon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _Field(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: !_showPassword,
                suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPassword = !_showPassword)),
              ),
              if (_isCreatingAccount) ...[
                const SizedBox(height: 12),
                _Field(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  icon: Icons.lock_reset_outlined,
                  obscureText: !_showConfirmPassword,
                  suffixIcon: IconButton(icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword)),
                ),
              ],
              if (!_isCreatingAccount)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: state.isLoading ? null : _forgotPassword, child: const Text('Forgot password?')),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: state.isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_isCreatingAccount ? 'CREATE ACCOUNT' : 'SIGN IN'),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: state.isLoading ? null : _googleSignIn,
                  icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontSize: 18)),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), side: const BorderSide(color: AppColors.cardBorder)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isCreatingAccount = !_isCreatingAccount),
                  child: Text(_isCreatingAccount ? 'Already have an account? Sign in' : 'New to ApnaCare? Create an account', style: AppTextStyles.bodySemiBold(color: AppColors.primary)),
                ),
              ),
              Center(child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Back', style: AppTextStyles.labelBold(color: AppColors.textMuted)))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? prefixText;
  final Widget? suffixIcon;

  const _Field({required this.controller, required this.label, required this.icon, this.keyboardType, this.obscureText = false, this.prefixText, this.suffixIcon});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          prefixText: prefixText,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.cardBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.cardBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
        ),
      );
}
