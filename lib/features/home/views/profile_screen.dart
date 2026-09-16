import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/domain/auth_provider.dart';

/// Patient profile surface. Demo profile data is shown when no backend profile
/// has been loaded yet; auth actions remain real when Firebase is enabled.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text('My profile', style: AppTextStyles.heading3()),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: () => _showDemoMessage(context, 'Settings are ready for backend preferences.'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _ProfileHeader(onEdit: () => _showDemoMessage(context, 'Profile editing is available in demo mode.')),
            const SizedBox(height: 18),
            const _ReadinessCard(),
            const SizedBox(height: 22),
            _sectionTitle('Personal details'),
            const SizedBox(height: 10),
            const _DetailsCard(),
            const SizedBox(height: 22),
            _sectionTitle('Care tools'),
            const SizedBox(height: 10),
            _ToolGrid(
              items: const [
                _ProfileTool(Icons.emergency_share_rounded, 'Emergency profile', 'Allergies & contacts'),
                _ProfileTool(Icons.people_alt_rounded, 'Care Circle', 'Family coordination'),
                _ProfileTool(Icons.folder_shared_rounded, 'Health vault', 'Reports & prescriptions'),
                _ProfileTool(Icons.notifications_active_rounded, 'Reminders', 'Care tasks & alerts'),
              ],
              onTap: (tool) => _showDemoMessage(context, '${tool.title} is available in demo mode.'),
            ),
            const SizedBox(height: 22),
            _sectionTitle('Account'),
            const SizedBox(height: 10),
            _AccountCard(onSignOut: () => _signOut(context, ref)),
          ],
        ),
      );

  Widget _sectionTitle(String title) => Text(title, style: AppTextStyles.heading3().copyWith(fontSize: 17));

  static void _showDemoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (_) => false);
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onEdit;
  const _ProfileHeader({required this.onEdit});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24), boxShadow: AppColors.elevatedShadow(opacity: 0.16)),
        child: Row(children: [
          const CircleAvatar(radius: 34, backgroundColor: Colors.white, child: Icon(Icons.person_rounded, size: 38, color: AppColors.primary)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ashmit Jain', style: AppTextStyles.heading3(color: Colors.white)),
            const SizedBox(height: 3),
            Text('Patient · New Delhi', style: AppTextStyles.label(color: Colors.white.withValues(alpha: 0.86))),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.verified_rounded, color: Colors.white, size: 15), const SizedBox(width: 5), Text('Demo profile verified', style: AppTextStyles.labelSmall(color: Colors.white))]),
          ])),
          IconButton(tooltip: 'Edit profile', onPressed: onEdit, style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18), foregroundColor: Colors.white), icon: const Icon(Icons.edit_outlined, size: 19)),
        ]),
      );
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.health_and_safety_rounded, color: AppColors.primary), const SizedBox(width: 9), Expanded(child: Text('Emergency readiness', style: AppTextStyles.bodySemiBold())), Text('80%', style: AppTextStyles.labelBold(color: AppColors.primaryDark))]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: const LinearProgressIndicator(value: 0.8, minHeight: 8, backgroundColor: AppColors.primaryLight, valueColor: AlwaysStoppedAnimation(AppColors.primary))),
          const SizedBox(height: 9),
          Text('Add your blood group to make emergency handoff faster.', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
        ]),
      );
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
        child: const Column(children: [
          _DetailRow(Icons.phone_outlined, 'Phone', '+91 98••• ••210'),
          _DetailRow(Icons.email_outlined, 'Email', 'ashmit.demo@apnacare.app'),
          _DetailRow(Icons.bloodtype_outlined, 'Blood group', 'Not added yet'),
          _DetailRow(Icons.location_on_outlined, 'Home area', 'Saket, New Delhi'),
        ]),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 12), Expanded(child: Text(label, style: AppTextStyles.label(color: AppColors.textMuted))), Flexible(child: Text(value, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelBold(color: AppColors.textPrimary)))]));
}

class _ProfileTool {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ProfileTool(this.icon, this.title, this.subtitle);
}

class _ToolGrid extends StatelessWidget {
  final List<_ProfileTool> items;
  final ValueChanged<_ProfileTool> onTap;
  const _ToolGrid({required this.items, required this.onTap});
  @override
  Widget build(BuildContext context) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4), itemBuilder: (_, index) { final tool = items[index]; return InkWell(onTap: () => onTap(tool), borderRadius: BorderRadius.circular(17), child: Ink(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.cardBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(tool.icon, color: AppColors.primary, size: 22), const SizedBox(height: 7), Text(tool.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelBold()), Text(tool.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelSmall(color: AppColors.textMuted))]))); });
}

class _AccountCard extends StatelessWidget {
  final VoidCallback onSignOut;
  const _AccountCard({required this.onSignOut});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.account_circle_outlined, color: AppColors.primaryDark), const SizedBox(width: 10), Expanded(child: Text('Demo data remains available for the showcase. Your Firebase session is signed out securely.', style: AppTextStyles.labelSmall(color: AppColors.textSecondary))), TextButton(onPressed: onSignOut, child: const Text('Sign out'))]));
}
