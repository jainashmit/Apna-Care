import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../domain/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: AppTextStyles.bodyMedium(color: Colors.white))));
  }

  Future<void> _signIn() async {
    final success = await ref.read(authProvider.notifier).signInWithEmail(email: _emailController.text, password: _passwordController.text);
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (state.error != null) {
      _showSnack(state.error!);
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
      _showSnack(state.error!);
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
    if (!completed && mounted) _showSnack(ref.read(authProvider).error ?? 'Please complete your profile.');
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
            const Text('Enter the email used for your ApnaCare account. The reset link is delivered only to that inbox; nobody can change a password by entering another email.'),
            const SizedBox(height: 14),
            TextField(controller: controller, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Account email')),
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
    _showSnack(success ? 'Password reset link sent to your email.' : (state.error ?? 'Could not send reset link.'));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
          Positioned(top: -100, right: -80, child: _Glow(size: 300, color: AppColors.primary)),
          Positioned(bottom: -60, left: -60, child: _Glow(size: 240, color: AppColors.secondary)),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 56),
                    const _FloatingGreenLogo(),
                    const SizedBox(height: 32),
                    Text('Welcome to ApnaCare', style: AppTextStyles.heading1()),
                    const SizedBox(height: 10),
                    Text('Your trusted healthcare companion. Sign in securely with email.', style: AppTextStyles.subHeader()),
                    const SizedBox(height: 34),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: AppColors.cardShadow(opacity: 0.08), border: Border.all(color: AppColors.cardBorder, width: 1.2)),
                      child: Column(children: [
                        _PillInputField(controller: _emailController, keyboardType: TextInputType.emailAddress, hintText: 'Email address', prefixIcon: Icons.alternate_email_rounded),
                        const SizedBox(height: 12),
                        _PillInputField(controller: _passwordController, hintText: 'Password', prefixIcon: Icons.lock_outline, obscureText: !_showPassword, suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPassword = !_showPassword))),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: state.isLoading ? null : _forgotPassword, child: const Text('Forgot password?'))),
                        _GreenPillButton(label: 'SIGN IN', isLoading: state.isLoading, onTap: state.isLoading ? null : _signIn),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: state.isLoading ? null : _googleSignIn,
                        icon: const Text('G', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 18)),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15), side: const BorderSide(color: AppColors.cardBorder, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(child: TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.emailAuth), child: Text('New to ApnaCare? Create an account', style: AppTextStyles.bodySemiBold(color: AppColors.primary)))),
                    const SizedBox(height: 32),
                    Center(child: Text('Your phone number is collected only for care coordination, never for login or SMS.', textAlign: TextAlign.center, style: AppTextStyles.labelSmall(color: AppColors.textMuted))),
                    SizedBox(height: size.height * 0.04),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0)])));
}

class _FloatingGreenLogo extends StatefulWidget {
  const _FloatingGreenLogo();
  @override
  State<_FloatingGreenLogo> createState() => _FloatingGreenLogoState();
}

class _FloatingGreenLogoState extends State<_FloatingGreenLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -_animation.value),
          child: Container(width: 80, height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: AppColors.primaryGradient, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, _animation.value + 10))]), child: const Icon(Icons.health_and_safety_outlined, size: 42, color: Colors.white)),
        ),
      );
}

class _PillInputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _PillInputField({required this.controller, required this.hintText, required this.prefixIcon, this.keyboardType, this.obscureText = false, this.suffixIcon});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: AppColors.primary),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.primaryLight.withValues(alpha: 0.4),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cardBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cardBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      );
}

class _GreenPillButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;
  const _GreenPillButton({required this.label, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(gradient: onTap == null ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]) : AppColors.primaryGradient, borderRadius: BorderRadius.circular(30), boxShadow: onTap == null ? [] : AppColors.greenShadow),
          child: Center(child: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text(label, style: AppTextStyles.button().copyWith(fontSize: 16))),
        ),
      );
}
