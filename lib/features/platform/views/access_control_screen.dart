import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/mock_access_repository.dart';
import '../domain/models/access_models.dart';

class OrganizationAccessScreen extends StatefulWidget {
  const OrganizationAccessScreen({super.key});

  @override
  State<OrganizationAccessScreen> createState() => _OrganizationAccessScreenState();
}

class _OrganizationAccessScreenState extends State<OrganizationAccessScreen> {
  final _repository = MockAccessRepository();
  late List<AccessRole> _roles;

  @override
  void initState() {
    super.initState();
    _roles = List.of(_repository.organization.roles);
  }

  void _openRole(AccessRole role) {
    final selected = role.permissionCodes.toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (context, setSheetState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(role.name, style: AppTextStyles.heading2())), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
            Text('${role.isCustom ? 'Custom role' : 'ApnaCare template'} · ${role.scope}', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
            const SizedBox(height: 18),
            Text('Permissions', style: AppTextStyles.heading3()),
            const SizedBox(height: 8),
            Expanded(child: ListView(children: _repository.permissions.map((permission) {
              final enabled = selected.contains('*') || selected.contains(permission.code);
              return SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(permission.label, style: AppTextStyles.bodyMedium()),
                subtitle: Text('${permission.group} · ${permission.code}', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                value: enabled,
                activeThumbColor: AppColors.primary,
                onChanged: role.id == 'owner'
                    ? null
                    : (value) => setSheetState(() {
                        if (value == true) {
                          selected.add(permission.code);
                        } else {
                          selected.remove(permission.code);
                        }
                      }),
              );
            }).toList())),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: role.id == 'owner' ? null : () { Navigator.pop(context); ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Role permissions saved in demo mode'))); }, child: const Text('Save permissions'))),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, surfaceTintColor: Colors.transparent, elevation: 0, title: Text('Organization access', style: AppTextStyles.heading3())),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(22)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.domain_rounded, color: Colors.white)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_organizationName, style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('Owner: $_ownerName', style: TextStyle(color: Colors.white70))])), const Icon(Icons.verified_rounded, color: Colors.white)])),
          const SizedBox(height: 24),
          Row(children: [Expanded(child: Text('Roles and access', style: AppTextStyles.heading3())), TextButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role builder coming next'))), icon: const Icon(Icons.add_rounded), label: const Text('New role'))]),
          const SizedBox(height: 8),
          ..._roles.map((role) => _RoleTile(role: role, onTap: () => _openRole(role))),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(17)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lock_outline_rounded, color: AppColors.primary), SizedBox(width: 9), Expanded(child: Text('Only the organization owner can change roles. Every permission change is recorded in the provider audit log.', style: TextStyle(color: AppColors.textSecondary, height: 1.4)))])),
        ]),
      );

  static const _organizationName = 'Apollo Clinic · Saket';
  static const _ownerName = 'Dr. Nisha Kapoor';
}

class _RoleTile extends StatelessWidget {
  final AccessRole role;
  final VoidCallback onTap;
  const _RoleTile({required this.role, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: onTap, tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.cardBorder)), leading: CircleAvatar(backgroundColor: role.isCustom ? AppColors.accentLight : AppColors.primaryLight, child: Icon(role.isCustom ? Icons.tune_rounded : Icons.shield_rounded, color: role.isCustom ? AppColors.accent : AppColors.primary)), title: Text(role.name, style: AppTextStyles.bodySemiBold()), subtitle: Text('${role.scope} · ${role.permissionCodes.contains('*') ? 'Full access' : '${role.permissionCodes.length} permissions'}', style: AppTextStyles.labelSmall(color: AppColors.textMuted)), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted)));
}
