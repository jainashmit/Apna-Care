import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/hospital_model.dart';
import '../../../core/widgets/premium_widgets.dart';

class HospitalDetailScreen extends StatelessWidget {
  final HospitalModel hospital;

  const HospitalDetailScreen({super.key, required this.hospital});

  Future<void> _openMaps(BuildContext context) async {
    // Basic Google Maps query URL
    final query = Uri.encodeComponent(hospital.name);
    final mapUrl = Uri.parse('google.navigation:q=$query');
    final fallbackUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(mapUrl);
      } else {
        // Fallback to browser
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open map. No supported app found.')),
            );
          }
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const PremiumBackgroundBlobs(),
          Column(
            children: [
              const SizedBox(height: 10),
              GlassAppBar(
                title: 'Hospital Details',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PremiumGlassCard(
                        width: double.infinity,
                        height: 220,
                        opacity: 0.15,
                        borderRadius: 32,
                        blur: 20,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const Text('🏥', style: TextStyle(fontSize: 90)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(hospital.name, style: AppTextStyles.heading2().copyWith(fontSize: 28)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  '${hospital.rating} (${hospital.reviewCount} reviews)',
                                  style: AppTextStyles.bodySemiBold(color: Colors.amber[900] ?? Colors.amber),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${hospital.distanceKm} km',
                                  style: AppTextStyles.bodySemiBold(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PremiumGlassCard(
                        padding: const EdgeInsets.all(20),
                        opacity: 0.05,
                        borderRadius: 24,
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.map_rounded, color: AppColors.textMuted, size: 20),
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
                      const SizedBox(height: 40),
                      Text('Medical Specialties', style: AppTextStyles.heading3().copyWith(fontSize: 22)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: hospital.specialties.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                            ),
                            child: Text(s, style: AppTextStyles.labelBold(color: AppColors.primary)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 60),
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _openMaps(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_rounded, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                'Get Directions',
                                style: AppTextStyles.button().copyWith(fontSize: 18),
                              ),
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
        ],
      ),
    );
  }
}

class _ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ModernIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}
