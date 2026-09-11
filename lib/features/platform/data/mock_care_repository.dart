import '../domain/models/care_models.dart';

/// Local data source for the complete frontend demo. Replace this class with
/// an API implementation without changing views or state consumers.
class MockCareRepository {
  final List<CareMember> _members = const [
    CareMember(id: 'me', name: 'Ashmit Jain', relation: 'Self', initials: 'AJ', healthNote: 'No active care plan'),
    CareMember(id: 'mom', name: 'Sunita Jain', relation: 'Mother', initials: 'SJ', healthNote: 'Cardiology follow-up', pendingTasks: 2),
    CareMember(id: 'dad', name: 'Rajesh Jain', relation: 'Father', initials: 'RJ', healthNote: 'Physiotherapy plan', pendingTasks: 1),
  ];

  final List<CareTask> _tasks = [
    CareTask(id: 't1', title: 'Upload ECG report', detail: 'For Dr. R. Mehta before Thursday', memberId: 'mom', dueAt: DateTime(2026, 9, 7, 18)),
    CareTask(id: 't2', title: 'Confirm physiotherapy visit', detail: 'Home visit, 10:00 AM', memberId: 'dad', dueAt: DateTime(2026, 9, 6, 10)),
    CareTask(id: 't3', title: 'Take vitamin D', detail: 'After breakfast', memberId: 'me', dueAt: DateTime(2026, 9, 6, 9), isComplete: true),
  ];

  List<CareMember> get members => List.unmodifiable(_members);
  List<CareTask> get tasks => List.unmodifiable(_tasks);

  List<CareAppointment> get appointments => [
        CareAppointment(id: 'a1', patientName: 'Sunita Jain', clinicianName: 'Dr. R. Mehta', specialty: 'Cardiology', startsAt: DateTime(2026, 9, 7, 11, 30), status: AppointmentStatus.confirmed, queueNumber: 8, location: 'Apollo Clinic, Saket'),
        CareAppointment(id: 'a2', patientName: 'Ashmit Jain', clinicianName: 'Dr. P. Singh', specialty: 'Orthopaedics', startsAt: DateTime(2026, 9, 10, 16), status: AppointmentStatus.confirmed, queueNumber: 3, location: 'Max Super Speciality'),
      ];

  EmergencyRequest get activeEmergency => const EmergencyRequest(
        id: 'e1', patientName: 'Sunita Jain', type: 'Cardiac support', location: 'Saket, New Delhi', status: EmergencyStatus.arriving, etaMinutes: 6, ambulanceLabel: 'ALS-24 · Apollo Emergency',
      );

  List<ProviderMetric> get doctorMetrics => const [
        ProviderMetric('Today', '18', 'appointments'),
        ProviderMetric('Waiting', '4', 'patients in queue'),
        ProviderMetric('Avg. wait', '12 min', 'this week'),
      ];

  List<ProviderMetric> get hospitalMetrics => const [
        ProviderMetric('Today’s visits', '142', '+18% vs last Tue'),
        ProviderMetric('Open slots', '26', 'across 8 departments'),
        ProviderMetric('Collection', '₹1.84L', 'estimated today'),
      ];

  List<ProviderMetric> get adminMetrics => const [
        ProviderMetric('Verified providers', '248', '12 awaiting review'),
        ProviderMetric('Bookings today', '1,842', '94% confirmation rate'),
        ProviderMetric('Emergency median', '8 min', 'dispatch to arrival'),
      ];

  Future<void> toggleTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index >= 0) _tasks[index] = _tasks[index].copyWith(isComplete: !_tasks[index].isComplete);
  }
}
