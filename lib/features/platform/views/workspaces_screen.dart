import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../domain/models/care_models.dart';
import '../domain/providers/care_provider.dart';

class CareHubScreen extends ConsumerWidget {
  const CareHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(careRepositoryProvider);
    final state = ref.watch(careProvider);
    final openTasks = state.tasks.where((task) => !task.isComplete).toList();
    return _WorkspaceScaffold(
      title: 'My Care Hub',
      subtitle: 'Your family’s care, in one safe place',
      actions: [
        IconButton(onPressed: () => Navigator.pushNamed(context, '/workspaces'), icon: const Icon(Icons.grid_view_rounded)),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _EmergencyStatusCard(request: repo.activeEmergency, onTap: () => Navigator.pushNamed(context, '/emergency-command')),
          const SizedBox(height: 24),
          _SectionTitle('Care Circle', action: 'Manage'),
          const SizedBox(height: 12),
          SizedBox(
            height: 114,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: repo.members.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                if (index == repo.members.length) return const _AddCircleMember();
                return _MemberCard(member: repo.members[index]);
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Next appointment', action: 'View all'),
          const SizedBox(height: 12),
          ...repo.appointments.take(1).map((appointment) => _AppointmentCard(appointment: appointment)),
          const SizedBox(height: 24),
          _SectionTitle('Care plan', action: '${openTasks.length} to do'),
          const SizedBox(height: 10),
          ...openTasks.map((task) => _TaskTile(task: task, onChanged: () => ref.read(careProvider.notifier).toggleTask(task.id))),
          const SizedBox(height: 20),
          _QuickActions(),
        ],
      ),
    );
  }
}

class WorkspacePickerScreen extends StatelessWidget {
  const WorkspacePickerScreen({super.key});

  @override
  Widget build(BuildContext context) => _WorkspaceScaffold(
        title: 'ApnaCare Workspaces',
        subtitle: 'One connected system. Switch roles to explore the demo.',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _WorkspaceTile(icon: Icons.favorite_rounded, color: AppColors.primary, title: 'Patient care hub', description: 'Care Circle, appointments, documents and care plans', onTap: () => Navigator.pushReplacementNamed(context, '/care-hub')),
            _WorkspaceTile(icon: Icons.vaccines_rounded, color: const Color(0xFF5C6BC0), title: 'Doctor workspace', description: 'Today’s schedule, queue and patient context', onTap: () => Navigator.pushNamed(context, '/doctor-workspace')),
            _WorkspaceTile(icon: Icons.local_hospital_rounded, color: const Color(0xFF00897B), title: 'Hospital operations', description: 'Departments, live capacity, billing and staff operations', onTap: () => Navigator.pushNamed(context, '/hospital-ops')),
            _WorkspaceTile(icon: Icons.admin_panel_settings_rounded, color: const Color(0xFF7E57C2), title: 'Platform admin', description: 'Provider verification, content, service quality and revenue', onTap: () => Navigator.pushNamed(context, '/platform-admin')),
          ],
        ),
      );
}

class DoctorWorkspaceScreen extends ConsumerWidget {
  const DoctorWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(careRepositoryProvider);
    return _WorkspaceScaffold(
      title: 'Good morning, Dr. Mehta',
      subtitle: 'Tuesday, 5 September · Apollo Clinic',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _MetricRow(metrics: repo.doctorMetrics),
          const SizedBox(height: 24),
          _SectionTitle('Live queue', action: 'Open calendar'),
          const SizedBox(height: 12),
          const _QueueCard(number: 5, patient: 'Mrs. Sunita Jain', note: 'Cardiology follow-up · reports attached', status: 'In 12 min'),
          const SizedBox(height: 12),
          const _QueueCard(number: 6, patient: 'Mr. Aarav Khanna', note: 'New consultation · chest discomfort', status: 'Check-in pending'),
          const SizedBox(height: 24),
          _SectionTitle('Practice tools'),
          const SizedBox(height: 12),
          const _ToolGrid(items: [
            _ToolItem(Icons.calendar_month_rounded, 'Availability', 'Manage slots'),
            _ToolItem(Icons.description_rounded, 'Visit notes', 'Draft & share'),
            _ToolItem(Icons.medication_rounded, 'Prescriptions', 'Templates'),
            _ToolItem(Icons.insights_rounded, 'Insights', 'Practice health'),
          ]),
        ],
      ),
    );
  }
}

class HospitalOperationsScreen extends ConsumerWidget {
  const HospitalOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(careRepositoryProvider);
    return _WorkspaceScaffold(
      title: 'Apollo Clinic Operations',
      subtitle: 'Saket · All systems operational',
      actions: [
        IconButton(onPressed: () => Navigator.pushNamed(context, '/organization-access'), icon: const Icon(Icons.manage_accounts_rounded)),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _MetricRow(metrics: repo.hospitalMetrics),
          const SizedBox(height: 24),
          _SectionTitle('Today at a glance', action: 'Operations board'),
          const SizedBox(height: 12),
          const _OperationsCard(),
          const SizedBox(height: 24),
          _SectionTitle('Control centre'),
          const SizedBox(height: 12),
          const _ToolGrid(items: [
            _ToolItem(Icons.people_alt_rounded, 'Appointments', 'Queues & slots'),
            _ToolItem(Icons.receipt_long_rounded, 'Billing', 'Invoices & payouts'),
            _ToolItem(Icons.badge_rounded, 'Staff', 'Rosters & access'),
            _ToolItem(Icons.inventory_2_rounded, 'Services', 'Fees & inventory'),
            _ToolItem(Icons.campaign_rounded, 'Offers', 'Campaigns'),
            _ToolItem(Icons.star_rounded, 'Quality', 'Reviews & SLA'),
          ]),
        ],
      ),
    );
  }
}

class PlatformAdminScreen extends ConsumerWidget {
  const PlatformAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(careRepositoryProvider);
    return _WorkspaceScaffold(
      title: 'Platform control centre',
      subtitle: 'ApnaCare network · Delhi NCR',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _MetricRow(metrics: repo.adminMetrics),
          const SizedBox(height: 24),
          _SectionTitle('Needs attention', action: 'See all'),
          const SizedBox(height: 12),
          const _AttentionTile(icon: Icons.verified_user_rounded, title: '12 provider verifications', detail: 'Licences and clinic documents awaiting review', color: Color(0xFFFF9800)),
          const SizedBox(height: 10),
          const _AttentionTile(icon: Icons.emergency_rounded, title: '2 ambulance coverage gaps', detail: 'South Delhi demand is above available fleet', color: AppColors.accent),
          const SizedBox(height: 10),
          const _AttentionTile(icon: Icons.health_and_safety_rounded, title: '97.6% safety compliance', detail: 'One provider needs a response-time review', color: AppColors.primary),
          const SizedBox(height: 24),
          _SectionTitle('Platform tools'),
          const SizedBox(height: 12),
          const _ToolGrid(items: [
            _ToolItem(Icons.domain_verification_rounded, 'Providers', 'Verify & manage'),
            _ToolItem(Icons.payments_rounded, 'Revenue', 'Plans & settlements'),
            _ToolItem(Icons.emergency_share_rounded, 'Emergency SLA', 'Coverage map'),
            _ToolItem(Icons.view_carousel_rounded, 'Content CMS', 'Banners & offers'),
          ]),
        ],
      ),
    );
  }
}

class EmergencyCommandScreen extends ConsumerWidget {
  const EmergencyCommandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(careRepositoryProvider).activeEmergency;
    return _WorkspaceScaffold(
      title: 'Emergency command',
      subtitle: 'Live request tracking · Demo mode',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(24), boxShadow: AppColors.elevatedShadow(opacity: 0.2)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.emergency_rounded, color: Colors.white), SizedBox(width: 8), Text('AMBULANCE IS ARRIVING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1))]),
              const SizedBox(height: 22),
              Text('${request.etaMinutes} min', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
              Text(request.ambulanceLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.86))),
            ]),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Response timeline'),
          const SizedBox(height: 12),
          const _TimelineItem(time: '10:12 AM', title: 'Emergency request created', detail: 'Cardiac support requested for Sunita Jain', completed: true),
          const _TimelineItem(time: '10:14 AM', title: 'ALS-24 assigned', detail: 'Apollo Emergency accepted the request', completed: true),
          const _TimelineItem(time: '10:18 AM', title: 'Ambulance en route', detail: 'Live ETA is 6 minutes', completed: false),
          const SizedBox(height: 24),
          const _SafetyCard(),
        ],
      ),
    );
  }
}

class _WorkspaceScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget>? actions;
  const _WorkspaceScaffold({required this.title, required this.subtitle, required this.child, this.actions});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 20,
          leading: Navigator.canPop(context) ? IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18)) : null,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.heading3()), Text(subtitle, style: AppTextStyles.labelSmall(color: AppColors.textMuted))]),
          actions: actions,
        ),
        body: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionTitle(this.title, {this.action});
  @override
  Widget build(BuildContext context) => Row(children: [Text(title, style: AppTextStyles.heading3()), const Spacer(), if (action != null) Text(action!, style: AppTextStyles.labelBold(color: AppColors.primary))]);
}

class _EmergencyStatusCard extends StatelessWidget {
  final EmergencyRequest request;
  final VoidCallback onTap;
  const _EmergencyStatusCard({required this.request, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.accent.withValues(alpha: 0.25))),
          child: Row(children: [
            Container(width: 46, height: 46, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: const Icon(Icons.emergency_rounded, color: Colors.white)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Emergency active · ${request.etaMinutes} min away', style: AppTextStyles.bodySemiBold().copyWith(fontSize: 14)), const SizedBox(height: 3), Text('${request.patientName} · ${request.ambulanceLabel}', style: AppTextStyles.labelSmall(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
          ]),
        ),
      );
}

class _MemberCard extends StatelessWidget {
  final CareMember member;
  const _MemberCard({required this.member});
  @override
  Widget build(BuildContext context) => Container(width: 136, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder), boxShadow: AppColors.cardShadow(opacity: 0.04)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 17, backgroundColor: AppColors.primaryLight, child: Text(member.initials, style: AppTextStyles.labelBold(color: AppColors.primaryDark))), const SizedBox(height: 8), Text(member.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelBold()), Text(member.relation, style: AppTextStyles.labelSmall(color: AppColors.textMuted)), if (member.pendingTasks > 0) Text('${member.pendingTasks} pending', style: AppTextStyles.labelSmall(color: AppColors.accent))]));
}

class _AddCircleMember extends StatelessWidget {
  const _AddCircleMember();
  @override
  Widget build(BuildContext context) => Container(width: 92, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary), SizedBox(height: 7), Text('Add member', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700))]));
}

class _AppointmentCard extends StatelessWidget {
  final CareAppointment appointment;
  const _AppointmentCard({required this.appointment});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appointment.clinicianName, style: AppTextStyles.bodySemiBold()), Text('${appointment.specialty} · ${appointment.patientName}', style: AppTextStyles.labelSmall(color: AppColors.textMuted)), const SizedBox(height: 4), Text('Sun, 7 Sep · 11:30 AM · Queue #${appointment.queueNumber}', style: AppTextStyles.labelSmall(color: AppColors.primaryDark))])), const Icon(Icons.chevron_right_rounded, color: AppColors.primary)]));
}

class _TaskTile extends StatelessWidget {
  final CareTask task;
  final VoidCallback onChanged;
  const _TaskTile({required this.task, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)), child: Row(children: [Checkbox(value: task.isComplete, activeColor: AppColors.primary, onChanged: (_) => onChanged()), const SizedBox(width: 5), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(task.title, style: AppTextStyles.labelBold()), Text(task.detail, style: AppTextStyles.labelSmall(color: AppColors.textMuted))]))]));
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const _ToolGrid(items: [
        _ToolItem(Icons.folder_shared_rounded, 'Health vault', 'Reports & files'),
        _ToolItem(Icons.medication_rounded, 'Medicines', 'Plans & reminders'),
        _ToolItem(Icons.smart_toy_rounded, 'Care Companion', 'Ask or organise'),
        _ToolItem(Icons.receipt_long_rounded, 'Care costs', 'Track spending'),
      ]);
}

class _MetricRow extends StatelessWidget {
  final List<ProviderMetric> metrics;
  const _MetricRow({required this.metrics});
  @override
  Widget build(BuildContext context) => Row(children: metrics.map((metric) => Expanded(child: Container(margin: EdgeInsets.only(right: metric == metrics.last ? 0 : 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(metric.value, style: AppTextStyles.heading3().copyWith(fontSize: 18)), Text(metric.label, style: AppTextStyles.labelSmall(color: AppColors.textSecondary)), Text(metric.detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelSmall(color: AppColors.textMuted))])))).toList());
}

class _QueueCard extends StatelessWidget {
  final int number; final String patient; final String note; final String status;
  const _QueueCard({required this.number, required this.patient, required this.note, required this.status});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder)), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: Text('#$number', style: AppTextStyles.labelBold(color: AppColors.primaryDark))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(patient, style: AppTextStyles.bodySemiBold()), Text(note, style: AppTextStyles.labelSmall(color: AppColors.textMuted))])), Text(status, style: AppTextStyles.labelBold(color: AppColors.primary))]));
}

class _OperationsCard extends StatelessWidget {
  const _OperationsCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Patient flow is healthy', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), SizedBox(height: 8), Text('OPD wait time is 12 min. Cardiology is approaching capacity at 82%.', style: TextStyle(color: Colors.white, height: 1.4)), SizedBox(height: 16), Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 8), Text('No critical service alerts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))])]));
}

class _AttentionTile extends StatelessWidget {
  final IconData icon; final String title; final String detail; final Color color;
  const _AttentionTile({required this.icon, required this.title, required this.detail, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)), child: Row(children: [Icon(icon, color: color), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.labelBold()), Text(detail, style: AppTextStyles.labelSmall(color: AppColors.textMuted))])), const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted)]));
}

class _TimelineItem extends StatelessWidget {
  final String time; final String title; final String detail; final bool completed;
  const _TimelineItem({required this.time, required this.title, required this.detail, required this.completed});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [Icon(completed ? Icons.check_circle_rounded : Icons.radio_button_checked_rounded, color: completed ? AppColors.primary : AppColors.accent), Container(width: 2, height: 40, color: AppColors.cardBorder)]), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$time · $title', style: AppTextStyles.labelBold()), Text(detail, style: AppTextStyles.labelSmall(color: AppColors.textMuted))]))]));
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(18)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.health_and_safety_rounded, color: AppColors.primary), SizedBox(width: 10), Expanded(child: Text('Emergency card, allergies and emergency contacts have been shared securely with the response team.', style: TextStyle(color: AppColors.textSecondary, height: 1.4)))]));
}

class _WorkspaceTile extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String description; final VoidCallback onTap;
  const _WorkspaceTile({required this.icon, required this.color, required this.title, required this.description, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Ink(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.22)), boxShadow: AppColors.cardShadow(opacity: 0.04)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.11), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.bodySemiBold()), const SizedBox(height: 3), Text(description, style: AppTextStyles.labelSmall(color: AppColors.textMuted))])), Icon(Icons.arrow_forward_ios_rounded, size: 15, color: color)]))));
}

class _ToolItem { final IconData icon; final String label; final String detail; const _ToolItem(this.icon, this.label, this.detail); }
class _ToolGrid extends StatelessWidget {
  final List<_ToolItem> items; const _ToolGrid({required this.items});
  @override
  Widget build(BuildContext context) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.55), itemBuilder: (_, i) { final item = items[i]; return Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.cardBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(item.icon, color: AppColors.primary, size: 21), const SizedBox(height: 6), Text(item.label, style: AppTextStyles.labelBold()), Text(item.detail, style: AppTextStyles.labelSmall(color: AppColors.textMuted))])); });
}
