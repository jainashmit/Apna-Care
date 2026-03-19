import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../domain/providers/doctor_provider.dart';
import '../views/doctor_detail_screen.dart';

class DoctorListScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const DoctorListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsByCategoryProvider(categoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const PremiumBackgroundBlobs(),
          Column(
            children: [
              const SizedBox(height: 10),
              GlassAppBar(
                title: categoryName,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: doctorsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (doctors) {
                    if (doctors.isEmpty) {
                      return const EmptyStateView(
                        title: 'No doctors found',
                        subtitle: 'There are currently no doctors available in this category.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      itemCount: doctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final doc = doctors[i];
                        return AnimatedInteractiveContainer(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailScreen(doctor: doc),
                              ),
                            );
                          },
                          child: PremiumGlassCard(
                            opacity: 0.2,
                            borderRadius:28,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'doctor_profile_${doc.id}',
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: AppColors.glassShadow(),
                                      border: Border.all(color: Colors.white, width: 2),
                                      image: doc.imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(doc.imageUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: doc.imageUrl == null
                                        ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 36)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(doc.name, style: AppTextStyles.bodySemiBold().copyWith(fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(doc.specialty, style: AppTextStyles.labelBold(color: AppColors.primary)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text('⭐', style: TextStyle(fontSize: 12)),
                                          const SizedBox(width: 4),
                                          Text(doc.rating.toString(), style: AppTextStyles.labelBold()),
                                          const SizedBox(width: 12),
                                          const Text('📍', style: TextStyle(fontSize: 12)),
                                          const SizedBox(width: 4),
                                          Text('${doc.distanceKm ?? "??"} km', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${doc.opdFee}', style: AppTextStyles.bodySemiBold(color: AppColors.primary).copyWith(fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text('per visit', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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
