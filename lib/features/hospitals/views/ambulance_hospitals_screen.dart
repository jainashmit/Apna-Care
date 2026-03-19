import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/hospital_model.dart';
import '../domain/providers/hospital_provider.dart';
import '../../../core/widgets/premium_widgets.dart';

class AmbulanceHospitalsScreen extends ConsumerWidget {
  const AmbulanceHospitalsScreen({super.key});

  Future<void> _callAmbulance(BuildContext context, {String number = '112'}) async {
    final uri = Uri.parse('tel:$number');
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(ambulanceHospitalsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const PremiumBackgroundBlobs(),
          Column(
            children: [
              const SizedBox(height: 10),
              GlassAppBar(
                title: 'Ambulance Service',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: hospitalsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (hospitals) => Column(
                    children: [
                      _SosBanner(onCall: () => _callAmbulance(context)),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                          itemCount: hospitals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, i) => _HospitalAmbulanceCard(
                            hospital: hospitals[i],
                            onCall: () => _callAmbulance(context),
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

class _SosBanner extends StatelessWidget {
  final VoidCallback onCall;
  const _SosBanner({required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: PremiumGlassCard(
        padding: const EdgeInsets.all(20),
        color: AppColors.accent,
        opacity: 0.9,
        borderRadius: 28,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        shadows: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Center(child: Text('🚨', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency? Call 112', style: AppTextStyles.bodySemiBold(color: Colors.white).copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Quick medical response unit', style: AppTextStyles.labelSmall(color: Colors.white70)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 0,
              ),
              child: Text('CALL', style: AppTextStyles.labelBold(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HospitalAmbulanceCard extends StatelessWidget {
  final HospitalModel hospital;
  final VoidCallback onCall;
  const _HospitalAmbulanceCard({required this.hospital, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveContainer(
      onTap: () {},
      child: PremiumGlassCard(
        padding: const EdgeInsets.all(16),
        opacity: 0.1,
        borderRadius: 28,
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppColors.glassShadow(),
                  ),
                  child: const Center(child: Text('🏨', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospital.name, style: AppTextStyles.bodySemiBold().copyWith(fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(hospital.address, style: AppTextStyles.labelSmall(color: AppColors.textMuted), maxLines: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(hospital.rating.toStringAsFixed(1), style: AppTextStyles.labelBold()),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('${hospital.distanceKm.toStringAsFixed(1)} km', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: hospital.specialties.take(2).map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(s, style: AppTextStyles.labelSmall(color: AppColors.primary)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('Call Hub', style: AppTextStyles.bodySemiBold(color: Colors.white).copyWith(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
