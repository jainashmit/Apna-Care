import '../../../auth/data/models/user_model.dart';

/// Abstract contract for auth operations.
abstract class AuthRepository {
  /// Create an account with email/password and a contact profile.
  Future<UserModel> createWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
  });

  /// Sign in with a verified email/password account.
  Future<UserModel> signInWithEmail({required String email, required String password});

  /// Send a free-tier email password reset link.
  Future<void> sendPasswordReset(String email);

  /// Sign in with Google. Returns authenticated [UserModel].
  Future<UserModel> signInWithGoogle();

  /// Sign out and clear session.
  Future<void> signOut();

  /// Returns the currently authenticated user, or null if not logged in.
  Future<UserModel?> getCurrentUser();
}
