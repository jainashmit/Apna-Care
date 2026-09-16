import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/firebase_bootstrap.dart';

/// Single write path for the booking UI. Firebase is used when configured;
/// local JSON keeps the showcase flow demonstrable without a backend.
class BookingService {
  const BookingService();

  Future<String> createAppointment({
    required String doctorId,
    required String doctorName,
    required String specialty,
    required String? hospitalName,
    required DateTime date,
    required String time,
    required int fee,
  }) async {
    final payload = <String, dynamic>{
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'hospitalName': hospitalName,
      'date': date.toIso8601String(),
      'time': time,
      'fee': fee,
      'status': 'confirmed',
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (FirebaseBootstrap.isReady && FirebaseAuth.instance.currentUser != null) {
      final user = FirebaseAuth.instance.currentUser;
      try {
        final ref = await FirebaseFirestore.instance.collection('appointments').add({
          ...payload,
          'patientId': user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _saveDemoCopy({...payload, 'id': ref.id});
        return ref.id;
      } on FirebaseException {
        // A showcase should remain usable if Firestore is not configured yet.
      }
    }

    final id = 'demo-${DateTime.now().millisecondsSinceEpoch}';
    await _saveDemoCopy({...payload, 'id': id});
    return id;
  }

  Future<void> _saveDemoCopy(Map<String, dynamic> booking) async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getStringList('demo_appointments') ?? <String>[];
    existing.add(jsonEncode(booking));
    await preferences.setStringList('demo_appointments', existing);
  }
}
