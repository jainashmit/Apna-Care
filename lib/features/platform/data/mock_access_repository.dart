import '../domain/models/access_models.dart';

class MockAccessRepository {
  final List<AccessPermission> permissions = const [
    AccessPermission('appointments.view', 'View appointments', 'Appointments'),
    AccessPermission('appointments.manage', 'Manage slots and queues', 'Appointments'),
    AccessPermission('patients.view', 'View patient profiles', 'Patient care'),
    AccessPermission('records.share', 'Share medical records', 'Patient care'),
    AccessPermission('billing.manage', 'Create invoices and refunds', 'Billing'),
    AccessPermission('ambulance.dispatch', 'Dispatch emergency vehicles', 'Emergency'),
    AccessPermission('reports.view', 'View operational reports', 'Reports'),
    AccessPermission('staff.manage', 'Invite and suspend staff', 'Administration'),
    AccessPermission('roles.manage', 'Create roles and assign access', 'Administration'),
  ];

  final ProviderOrganization organization = ProviderOrganization(
    id: 'org-apollo-saket',
    name: 'Apollo Clinic · Saket',
    kind: ProviderKind.clinic,
    ownerName: 'Dr. Nisha Kapoor',
    roles: const [
      AccessRole(id: 'owner', name: 'Organization owner', scope: 'Entire clinic', isCustom: false, permissionCodes: ['*']),
      AccessRole(id: 'reception', name: 'Front desk', scope: 'Appointments', isCustom: false, permissionCodes: ['appointments.view', 'appointments.manage', 'patients.view']),
      AccessRole(id: 'billing', name: 'Billing desk', scope: 'Finance', isCustom: false, permissionCodes: ['billing.manage', 'reports.view']),
      AccessRole(id: 'custom-night', name: 'Night coordinator', scope: 'Emergency desk', isCustom: true, permissionCodes: ['appointments.view', 'patients.view', 'ambulance.dispatch']),
    ],
  );
}
