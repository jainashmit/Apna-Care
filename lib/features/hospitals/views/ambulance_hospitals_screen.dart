import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/hd_network_image.dart';
import '../data/models/hospital_model.dart';
import '../domain/providers/hospital_provider.dart';
import 'hospital_detail_screen.dart';

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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.cardShadow(opacity: 0.06),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ambulance Service', style: AppTextStyles.heading2()),
                        Text(
                          'Emergency dispatch & patient transport',
                          style: AppTextStyles.labelSmall(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: hospitalsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (hospitals) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  children: [
                    // ── SOS Banner — professional pulsing design
                    _SosBanner(onCall: () => _callAmbulance(context)),
                    const SizedBox(height: 24),

                    // ── Section subtitle
                    Text(
                      'Nearby Ambulance Services',
                      style: AppTextStyles.heading3(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap a hospital to view details or call for emergency dispatch.',
                      style: AppTextStyles.subHeader(),
                    ),
                    const SizedBox(height: 16),

                    // ── Hospital cards
                    ...hospitals.asMap().entries.map((entry) {
                      final i = entry.key;
                      final hospital = entry.value;
                      final ambulanceTypes = [
                        _AmbulanceType(
                          icon: Icons.airport_shuttle_rounded,
                          label: 'Basic Life Support',
                          color: const Color(0xFF4CAF50),
                        ),
                        _AmbulanceType(
                          icon: Icons.local_shipping_rounded,
                          label: 'Advanced Life Support',
                          color: const Color(0xFF1E88E5),
                        ),
                        _AmbulanceType(
                          icon: Icons.directions_car_rounded,
                          label: 'Patient Transport',
                          color: const Color(0xFFFF8F00),
                        ),
                      ];
                      final ambType = ambulanceTypes[i % ambulanceTypes.length];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AmbulanceCard(
                          hospital: hospital,
                          ambType: ambType,
                          onCall: () => _callAmbulance(context),
                          onViewDetails: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HospitalDetailScreen(hospital: hospital),
                            ),
                          ),
                        ),
                      );
                    }),
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

// ─────────────────────────────────────────────────
// SOS BANNER — professional with pulsing ring animation
// ─────────────────────────────────────────────────
class _SosBanner extends StatefulWidget {
  final VoidCallback onCall;
  const _SosBanner({required this.onCall});

  @override
  State<_SosBanner> createState() => _SosBannerState();
}

class _SosBannerState extends State<_SosBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.40),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing emergency icon
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, __) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: const Center(
                    child: Icon(Icons.emergency_rounded, size: 26, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency? Call 112',
                  style: AppTextStyles.bodySemiBold(color: Colors.white)
                      .copyWith(fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  'Quick medical response unit. Average ETA: 8 min',
                  style: AppTextStyles.labelSmall(
                    color: Colors.white.withValues(alpha: 0.80),
                  ).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_in_talk_rounded,
                      size: 20, color: AppColors.accent),
                  const SizedBox(height: 2),
                  Text(
                    'CALL',
                    style: AppTextStyles.labelBold(color: AppColors.accent)
                        .copyWith(fontSize: 11, letterSpacing: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// AMBULANCE TYPE MODEL
// ─────────────────────────────────────────────────
class _AmbulanceType {
  final IconData icon;
  final String label;
  final Color color;
  const _AmbulanceType({required this.icon, required this.label, required this.color});
}

// ─────────────────────────────────────────────────
// AMBULANCE CARD — premium with hospital photo,
// two-button action row, navigation to HospitalDetailScreen
// ─────────────────────────────────────────────────
class _AmbulanceCard extends StatelessWidget {
  final HospitalModel hospital;
  final _AmbulanceType ambType;
  final VoidCallback onCall;
  final VoidCallback onViewDetails;

  const _AmbulanceCard({
    required this.hospital,
    required this.ambType,
    required this.onCall,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow(opacity: 0.07),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // ── Hospital photo header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 88,
              width: double.infinity,
              child: Stack(
                children: [
                  // Hospital image
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: hdHospitalUrl(hospital.name),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: const Color(0xFFDCEFDC),
                        highlightColor: const Color(0xFFF2FAF2),
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFCEE9C3),
                        child: const Center(
                          child: Icon(Icons.local_hospital_rounded,
                              size: 34, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  // Gradient scrim for readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.60),
                            Colors.black.withValues(alpha: 0.10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Ambulance type badge — top left
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: ambType.color.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(ambType.icon, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            ambType.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Hospital name + address at bottom of photo
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hospital.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(blurRadius: 4, color: Colors.black54),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Rating pill on image
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 11, color: AppColors.star),
                              const SizedBox(width: 3),
                              Text(
                                hospital.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address + distance row
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: AppTextStyles.labelSmall(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.route_rounded,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(
                      '${hospital.distanceKm.toStringAsFixed(1)} km',
                      style: AppTextStyles.labelBold(color: AppColors.textMuted)
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Two-button action row
                Row(
                  children: [
                    // View Details — outlined pill
                    Expanded(
                      child: GestureDetector(
                        onTap: onViewDetails,
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_hospital_outlined,
                                  size: 15, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'View Details',
                                style: AppTextStyles.labelBold(color: AppColors.primary)
                                    .copyWith(fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Call Hub — filled accent pill
                    Expanded(
                      child: GestureDetector(
                        onTap: onCall,
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone_in_talk_rounded,
                                  size: 15, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Call Hub',
                                style: AppTextStyles.bodySemiBold(color: Colors.white)
                                    .copyWith(fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
