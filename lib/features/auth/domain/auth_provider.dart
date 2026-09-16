import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/services/firebase_bootstrap.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool needsProfileCompletion;

  const AuthState({this.isLoading = false, this.error, this.needsProfileCompletion = false});

  AuthState copyWith({bool? isLoading, String? error, bool? needsProfileCompletion, bool clearError = false}) => AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        needsProfileCompletion: needsProfileCompletion ?? this.needsProfileCompletion,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  bool _googleInitialized = false;

  @override
  AuthState build() => const AuthState();

  Future<bool> signInWithEmail({required String email, required String password}) async {
    if (!_validateEmail(email) || password.length < 6) {
      state = state.copyWith(error: !_validateEmail(email) ? 'Enter a valid email address' : 'Password must be at least 6 characters');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    if (!FirebaseBootstrap.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false);
      return true;
    }
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password);
      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        state = state.copyWith(isLoading: false, error: 'Verify your email first. A new verification link was sent.');
        return false;
      }
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (exception) {
      state = state.copyWith(isLoading: false, error: exception.message ?? 'Email sign-in failed');
      return false;
    }
  }

  Future<bool> createEmailAccount({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().length < 2) {
      state = state.copyWith(error: 'Enter your full name');
      return false;
    }
    if (!_validateEmail(email)) {
      state = state.copyWith(error: 'Enter a valid email address');
      return false;
    }
    if (phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      state = state.copyWith(error: 'Enter a valid contact number');
      return false;
    }
    if (city.trim().length < 2) {
      state = state.copyWith(error: 'Enter your city');
      return false;
    }
    if (password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters');
      return false;
    }
    if (password != confirmPassword) {
      state = state.copyWith(error: 'Passwords do not match');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    if (!FirebaseBootstrap.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false);
      return true;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.trim(), password: password);
      final user = credential.user;
      await user?.updateDisplayName(name.trim());
      await user?.sendEmailVerification();
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'city': city.trim(),
          'role': 'patient',
          'photoUrl': user.photoURL,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await FirebaseAuth.instance.signOut();
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (exception) {
      state = state.copyWith(isLoading: false, error: exception.message ?? 'Could not create account');
      return false;
    } on FirebaseException catch (exception) {
      state = state.copyWith(isLoading: false, error: exception.message ?? 'Could not save your profile');
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    if (!_validateEmail(email)) {
      state = state.copyWith(error: 'Enter a valid email address');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    if (!FirebaseBootstrap.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      state = state.copyWith(isLoading: false);
      return true;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (exception) {
      state = state.copyWith(isLoading: false, error: exception.message ?? 'Could not send reset email');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    if (!FirebaseBootstrap.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false);
      return true;
    }
    try {
      final googleSignIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await googleSignIn.initialize();
        _googleInitialized = true;
      }
      final account = await googleSignIn.authenticate();
      final googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      var profileComplete = false;
      if (user != null) {
        final profile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = profile.data();
        profileComplete = (data?['phone'] as String?)?.trim().isNotEmpty == true && (data?['city'] as String?)?.trim().isNotEmpty == true;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'role': 'patient',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      state = state.copyWith(isLoading: false, needsProfileCompletion: !profileComplete);
      return true;
    } on GoogleSignInException catch (exception) {
      state = state.copyWith(isLoading: false, error: exception.description ?? 'Google sign-in was cancelled');
      return false;
    } on FirebaseAuthException catch (exception) {
      state = state.copyWith(isLoading: false, error: exception.message ?? 'Google sign-in failed');
      return false;
    } on FirebaseException catch (exception) {
      state = state.copyWith(isLoading: false, error: exception.message ?? 'Could not save your Google profile');
      return false;
    }
  }

  Future<bool> completeGoogleProfile({required String phone, required String city}) async {
    if (phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      state = state.copyWith(error: 'Enter a valid contact number');
      return false;
    }
    if (city.trim().length < 2) {
      state = state.copyWith(error: 'Enter your city');
      return false;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (FirebaseBootstrap.isReady && user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'phone': phone.trim(),
          'city': city.trim(),
          'emailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } on FirebaseException catch (exception) {
        state = state.copyWith(error: exception.message ?? 'Could not save your profile');
        return false;
      }
    }
    state = state.copyWith(needsProfileCompletion: false, clearError: true);
    return true;
  }

  Future<void> signOut() async {
    if (FirebaseBootstrap.isReady) {
      await FirebaseAuth.instance.signOut();
      if (_googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    }
    state = const AuthState();
  }

  bool _validateEmail(String value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
