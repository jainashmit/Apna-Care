import '../../../auth/data/models/user_model.dart';

/// Abstract contract for auth operations.
abstract class AuthRepository {
  /// Send OTP to [mobile] number. Returns true if sent successfully.
  Future<bool> sendOtp(String mobile);

  /// Verify [otp] for [mobile]. Returns authenticated [UserModel] on success.
  Future<UserModel> verifyOtp({required String mobile, required String otp});

  /// Sign in with Google. Returns authenticated [UserModel].
  Future<UserModel> signInWithGoogle();

  /// Sign out and clear session.
  Future<void> signOut();

  /// Returns the currently authenticated user, or null if not logged in.
  Future<UserModel?> getCurrentUser();
}
