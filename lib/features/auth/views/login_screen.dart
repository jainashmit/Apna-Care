import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../domain/auth_provider.dart';
import '../../../core/widgets/premium_widgets.dart';
import 'dart:ui';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.bodyMedium(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handlePrimary() async {
    final notifier = ref.read(authProvider.notifier);
    final state = ref.read(authProvider);

    if (!state.isOtpSent) {
      notifier.setMobile(_mobileController.text);
      await notifier.sendOtp();
      final newState = ref.read(authProvider);
      if (newState.error != null) _showSnack(newState.error!);
    } else {
      final success = await notifier.verifyOtp(_otpController.text);
      if (!success) {
        final newState = ref.read(authProvider);
        if (newState.error != null) _showSnack(newState.error!);
      } else {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Premium Background Orbs ──
          const PremiumBackgroundBlobs(),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      // 3D Logo
                      _Floating3DLogo(),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        state.isOtpSent ? 'Verify OTP' : 'Let\'s Get Started',
                        style: AppTextStyles.heading1(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.isOtpSent
                            ? 'We\'ve sent a 6-digit code to +91 ${state.mobile}'
                            : 'Enter your mobile number to continue',
                        style: AppTextStyles.subHeader(),
                      ),

                      const SizedBox(height: 48),

                      // Glass Input Card
                      PremiumGlassCard(
                        padding: const EdgeInsets.all(24),
                        opacity: 0.3,
                        blur: 25,
                        borderRadius: 32,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                        child: Column(
                          children: [
                            if (!state.isOtpSent)
                              TextField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: AppTextStyles.bodySemiBold().copyWith(letterSpacing: 1.5, fontSize: 18),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Mobile Number',
                                  prefixText: '+91  ',
                                  prefixStyle: AppTextStyles.bodySemiBold(color: AppColors.primary),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                                ),
                              )
                            else
                              TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textAlign: TextAlign.center,
                                style: AppTextStyles.heading1().copyWith(letterSpacing: 18),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  hintText: '------',
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),

                            const SizedBox(height: 32),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : _handlePrimary,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: state.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Text(
                                        state.isOtpSent ? 'VERIFY & CONTINUE' : 'GET OTP',
                                        style: AppTextStyles.button().copyWith(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Footer
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'By continuing, you agree to our',
                              style: AppTextStyles.labelSmall(color: AppColors.textMuted),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text('Terms of Service',
                                      style: AppTextStyles.labelBold(color: AppColors.primary)),
                                ),
                                Text('•', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                                TextButton(
                                  onPressed: () {},
                                  child: Text('Privacy Policy',
                                      style: AppTextStyles.labelBold(color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Secondary Login
                      if (!state.isOtpSent)
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Text('G', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                          label: Text('Continue with Google', style: AppTextStyles.bodyMedium()),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),

                      if (state.isOtpSent)
                        Center(
                          child: TextButton(
                            onPressed: () => ref.read(authProvider.notifier).goBackToMobile(),
                            child: Text('Change mobile number', style: AppTextStyles.bodySemiBold(color: AppColors.primary)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Floating3DLogo extends StatefulWidget {
  @override
  State<_Floating3DLogo> createState() => _Floating3DLogoState();
}

class _Floating3DLogoState extends State<_Floating3DLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 12).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, _animation.value + 10),
                ),
              ],
            ),
            child: const Center(child: Text('🏠', style: TextStyle(fontSize: 40))),
          ),
        );
      },
    );
  }
}
