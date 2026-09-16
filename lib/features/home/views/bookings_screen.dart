import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text('My bookings', style: AppTextStyles.heading3()),
            bottom: const TabBar(tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')]),
          ),
          body: const TabBarView(children: [_UpcomingBookings(), _PastBookings()]),
        ),
      );
}

class _UpcomingBookings extends StatefulWidget {
  const _UpcomingBookings();

  @override
  State<_UpcomingBookings> createState() => _UpcomingBookingsState();
}

class _UpcomingBookingsState extends State<_UpcomingBookings> {
  List<Map<String, dynamic>> _saved = const [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList('demo_appointments') ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _saved = values.map((value) {
        try {
          return Map<String, dynamic>.from(jsonDecode(value) as Map);
        } catch (_) {
          return <String, dynamic>{};
        }
      }).where((item) => item.isNotEmpty).toList().reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      const _BookingCard(
        date: 'SUN, 7 SEP',
        time: '11:30 AM',
        doctor: 'Dr. Nisha Kapoor',
        specialty: 'Cardiology · Apollo Clinic',
        status: 'Confirmed',
        color: AppColors.primary,
      ),
      const SizedBox(height: 12),
      const _BookingCard(
        date: 'WED, 10 SEP',
        time: '04:00 PM',
        doctor: 'Dr. Rohan Mehta',
        specialty: 'ENT · CarePoint Hospital',
        status: 'Payment pending',
        color: AppColors.accent,
      ),
    ];
    for (final booking in _saved) {
      final date = DateTime.tryParse(booking['date'] as String? ?? '');
      cards.add(const SizedBox(height: 12));
      cards.add(_BookingCard(
        date: date == null ? 'NEW BOOKING' : _formatDate(date),
        time: booking['time'] as String? ?? 'Time pending',
        doctor: booking['doctorName'] as String? ?? 'Doctor',
        specialty: '${booking['specialty'] ?? 'Consultation'} · ${booking['hospitalName'] ?? 'ApnaCare'}',
        status: 'Confirmed',
        color: AppColors.primary,
      ));
    }
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), children: cards);
  }

  String _formatDate(DateTime date) {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class _PastBookings extends StatelessWidget {
  const _PastBookings();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: const [
          _BookingCard(date: 'MON, 1 SEP', time: '10:00 AM', doctor: 'Dr. Ananya Shah', specialty: 'General medicine · Online', status: 'Completed', color: AppColors.textMuted),
        ],
      );
}

class _BookingCard extends StatelessWidget {
  final String date;
  final String time;
  final String doctor;
  final String specialty;
  final String status;
  final Color color;
  const _BookingCard({required this.date, required this.time, required this.doctor, required this.specialty, required this.status, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(date, style: AppTextStyles.labelBold(color: color))),
            const Spacer(),
            Text(status, style: AppTextStyles.labelBold(color: color)),
          ]),
          const SizedBox(height: 14),
          Text(doctor, style: AppTextStyles.bodySemiBold()),
          const SizedBox(height: 3),
          Text(specialty, style: AppTextStyles.label(color: AppColors.textMuted)),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.schedule_rounded, size: 17, color: AppColors.primary), const SizedBox(width: 6), Text(time, style: AppTextStyles.labelBold(color: AppColors.primaryDark)), const Spacer(), TextButton(onPressed: () {}, child: const Text('View details'))]),
        ]),
      );
}
