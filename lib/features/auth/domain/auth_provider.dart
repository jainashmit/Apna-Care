import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ─────────────────────────────────────────────────────
class AuthState {
  final String mobile;
  final bool isOtpSent;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.mobile = '',
    this.isOtpSent = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? mobile,
    bool? isOtpSent,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      mobile: mobile ?? this.mobile,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void setMobile(String value) {
    state = state.copyWith(mobile: value, error: null);
  }

  Future<void> sendOtp() async {
    if (state.mobile.length < 10) {
      state = state.copyWith(error: 'Enter a valid 10-digit mobile number');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false, isOtpSent: true);
  }

  Future<bool> verifyOtp(String otp) async {
    if (otp.length < 4) {
      state = state.copyWith(error: 'Enter a valid OTP');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false);
    return true; // Always succeeds in mock
  }

  void reset() {
    state = const AuthState();
  }

  void goBackToMobile() {
    state = state.copyWith(isOtpSent: false, error: null);
  }
}

// ── Provider ──────────────────────────────────────────────────
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
