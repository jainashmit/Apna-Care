import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/hospital_model.dart';


class HospitalDetailScreen extends StatelessWidget {
  final HospitalModel hospital;

  const HospitalDetailScreen({super.key, required this.hospital});

  Future<void> _openMaps(BuildContext context) async {
    final query = Uri.encodeComponent(hospital.name);
    final mapUrl = Uri.parse('google.navigation:q=$query');
    final fallbackUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(mapUrl);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open map.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Integrated header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.cardShadow(opacity: 0.06),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Hospital Details', style: AppTextStyles.heading2()),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hospital icon hero card
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppColors.cardShadow(opacity: 0.06),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.local_hospital_rounded, size: 46, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                hospital.specialties.isNotEmpty ? hospital.specialties.first : 'Multi-Specialty',
                                style: AppTextStyles.labelBold(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name + badges
                    Text(hospital.name, style: AppTextStyles.heading2()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.star_rounded,
                          label: '${hospital.rating} (${hospital.reviewCount} reviews)',
                          color: Colors.amber[700]!,
                          bgColor: Colors.amber.shade50,
                        ),
                        _InfoChip(
                          icon: Icons.location_on_rounded,
                          label: '${hospital.distanceKm} km away',
                          color: AppColors.primary,
                          bgColor: AppColors.primaryLight,
                        ),
                        if (hospital.verified)
                          _InfoChip(
                            icon: Icons.verified_rounded,
                            label: hospital.isLive ? 'Live listing' : 'ApnaCare verified',
                            color: AppColors.primary,
                            bgColor: AppColors.primaryLight,
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Address card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppColors.cardShadow(opacity: 0.04),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hospital.address,
                              style: AppTextStyles.bodyMedium(color: AppColors.textMuted).copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Trust and availability summary. These fields are also
                    // part of the future provider API contract.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.schedule_rounded,
                            label: 'Hours',
                            value: hospital.openHours,
                          ),
                          const Divider(height: 20),
                          _DetailRow(
                            icon: Icons.people_alt_outlined,
                            label: 'Doctors available',
                            value: '${hospital.availableDoctors} specialists today',
                          ),
                          const Divider(height: 20),
                          _DetailRow(
                            icon: Icons.shield_outlined,
                            label: 'Payment & coverage',
                            value: hospital.acceptsInsurance
                                ? 'Insurance and UPI accepted'
                                : 'Self-pay only',
                          ),
                          if (hospital.hasEmergency) ...[
                            const Divider(height: 20),
                            _DetailRow(
                              icon: Icons.emergency_rounded,
                              label: 'Emergency response',
                              value: 'Typical arrival ${hospital.emergencyWait}',
                              valueColor: Colors.red.shade700,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text('Services available', style: AppTextStyles.heading3()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hospital.services.map((service) {
                        return _ServicePill(label: service);
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    Text('Medical Specialties', style: AppTextStyles.heading3()),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: hospital.specialties.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppColors.cardShadow(opacity: 0.04),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                          ),
                          child: Text(s, style: AppTextStyles.labelBold(color: AppColors.primary)),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 36),

                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final phone = Uri.parse('tel:${hospital.phone.replaceAll(' ', '')}');
                              if (!await launchUrl(phone) && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Calling is unavailable in this demo.')),
                                );
                              }
                            },
                            icon: const Icon(Icons.call_outlined),
                            label: const Text('Call hospital'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Appointment flow ready for Firebase booking.')),
                              );
                            },
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: const Text('Book OPD'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Get Directions button — green pill
                    GestureDetector(
                      onTap: () => _openMaps(context),
                      child: Container(
                        height: 58,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppColors.greenShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text('Get Directions', style: AppTextStyles.button().copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  const _InfoChip({required this.icon, required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.bodySemiBold(color: color).copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium(color: AppColors.textMuted))),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySemiBold(color: valueColor ?? AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _ServicePill extends StatelessWidget {
  final String label;

  const _ServicePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: AppTextStyles.labelBold(color: AppColors.primary)),
    );
  }
}
