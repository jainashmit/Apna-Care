/// Shared product entities. These mirror the API contracts the backend will
/// eventually expose, while allowing the frontend to run entirely on demo data.
enum WorkspaceRole { patient, doctor, hospitalAdmin, platformAdmin }

enum AppointmentStatus { confirmed, waiting, completed, cancelled }

enum EmergencyStatus { requested, assigned, arriving, completed }

class CareMember {
  final String id;
  final String name;
  final String relation;
  final String initials;
  final String healthNote;
  final int pendingTasks;

  const CareMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.initials,
    required this.healthNote,
    this.pendingTasks = 0,
  });
}

class CareTask {
  final String id;
  final String title;
  final String detail;
  final String memberId;
  final DateTime dueAt;
  final bool isComplete;

  const CareTask({
    required this.id,
    required this.title,
    required this.detail,
    required this.memberId,
    required this.dueAt,
    this.isComplete = false,
  });

  CareTask copyWith({bool? isComplete}) => CareTask(
        id: id,
        title: title,
        detail: detail,
        memberId: memberId,
        dueAt: dueAt,
        isComplete: isComplete ?? this.isComplete,
      );
}

class CareAppointment {
  final String id;
  final String patientName;
  final String clinicianName;
  final String specialty;
  final DateTime startsAt;
  final AppointmentStatus status;
  final int queueNumber;
  final String location;

  const CareAppointment({
    required this.id,
    required this.patientName,
    required this.clinicianName,
    required this.specialty,
    required this.startsAt,
    required this.status,
    required this.queueNumber,
    required this.location,
  });
}

class EmergencyRequest {
  final String id;
  final String patientName;
  final String type;
  final String location;
  final EmergencyStatus status;
  final int etaMinutes;
  final String ambulanceLabel;

  const EmergencyRequest({
    required this.id,
    required this.patientName,
    required this.type,
    required this.location,
    required this.status,
    required this.etaMinutes,
    required this.ambulanceLabel,
  });
}

class ProviderMetric {
  final String label;
  final String value;
  final String detail;

  const ProviderMetric(this.label, this.value, this.detail);
}
