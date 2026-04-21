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
      SnackBar(content: Text(msg, style: AppTextStyles.bodyMedium(color: Colors.white))),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Soft green wash background
          Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          ),
          // Top-right green blob
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ]),
              ),
            ),
          ),
          // Bottom-left green blob
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.secondary.withValues(alpha: 0.12),
                  AppColors.secondary.withValues(alpha: 0.0),
                ]),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 56),

                      // Logo
                      _FloatingGreenLogo(),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        state.isOtpSent ? 'Verify OTP' : 'Let\'s Get Started',
                        style: AppTextStyles.heading1(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.isOtpSent
                            ? 'We\'ve sent a 6-digit code to +91 ${state.mobile}'
                            : 'Enter your mobile number to continue',
                        style: AppTextStyles.subHeader(),
                      ),

                      const SizedBox(height: 44),

                      // Input Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppColors.cardShadow(opacity: 0.08),
                          border: Border.all(color: AppColors.cardBorder, width: 1.2),
                        ),
                        child: Column(
                          children: [
                            if (!state.isOtpSent)
                              _PillInputField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                hintText: 'Mobile Number',
                                prefixText: '+91  ',
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                letterSpacing: 1.5,
                                fontSize: 18,
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                child: TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.heading1().copyWith(letterSpacing: 18),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    hintText: '------',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: _GreenPillButton(
                                label: state.isOtpSent ? 'VERIFY & CONTINUE' : 'GET OTP',
                                isLoading: state.isLoading,
                                onTap: state.isLoading ? null : _handlePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Google sign-in option
                      if (!state.isOtpSent)
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.shade50,
                              ),
                              child: const Center(
                                child: Text('G',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ),
                            ),
                            label: Text('Continue with Google', style: AppTextStyles.bodyMedium()),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                              side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                          ),
                        ),

                      if (state.isOtpSent)
                        Center(
                          child: TextButton(
                            onPressed: () => ref.read(authProvider.notifier).goBackToMobile(),
                            child: Text('Change mobile number',
                                style: AppTextStyles.bodySemiBold(color: AppColors.primary)),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Footer
                      Center(
                        child: Column(
                          children: [
                            Text('By continuing, you agree to our',
                                style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
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
                      SizedBox(height: size.height * 0.04),
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

// ── Floating Green Logo ───────────────────────────────────────
class _FloatingGreenLogo extends StatefulWidget {
  @override
  State<_FloatingGreenLogo> createState() => _FloatingGreenLogoState();
}

class _FloatingGreenLogoState extends State<_FloatingGreenLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
            child: const Center(
              child: Icon(Icons.health_and_safety_outlined, size: 42, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

// ── Pill Input Field ──────────────────────────────────────────
class _PillInputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;
  final String hintText;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final double letterSpacing;
  final double fontSize;

  const _PillInputField({
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    this.maxLength,
    this.prefixText,
    this.inputFormatters,
    this.letterSpacing = 0,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: AppTextStyles.bodySemiBold()
            .copyWith(letterSpacing: letterSpacing, fontSize: fontSize),
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          prefixText: prefixText,
          prefixStyle: AppTextStyles.bodySemiBold(color: AppColors.primary),
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.textHint),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: AppColors.primaryLight.withValues(alpha: 0.4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// ── Green Pill Button ─────────────────────────────────────────
class _GreenPillButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _GreenPillButton({
    required this.label,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: onTap == null
              ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: onTap == null ? [] : AppColors.greenShadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(label, style: AppTextStyles.button().copyWith(fontSize: 16)),
        ),
      ),
    );
  }
}
