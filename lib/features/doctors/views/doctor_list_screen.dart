import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/hd_network_image.dart';
import '../domain/providers/doctor_provider.dart';
import '../views/doctor_detail_screen.dart';
import '../data/models/doctor_model.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const DoctorListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsByCategoryProvider(widget.categoryId));

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
                    child: Text('Doctor List', style: AppTextStyles.heading2()),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.cardShadow(opacity: 0.06),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.notifications_outlined, size: 20, color: AppColors.textPrimary),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Pill search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.cardShadow(opacity: 0.06),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(6),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Search Nearest Available Doctor |',
                        style: AppTextStyles.subHeader(color: AppColors.textHint),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // ── Doctor grid
            Expanded(
              child: doctorsAsync.when(
                loading: () => _ShimmerDoctorGrid(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (doctors) {
                  if (doctors.isEmpty) {
                    return const EmptyStateView(
                      title: 'No doctors found',
                      subtitle: 'There are currently no doctors available in this category.',
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: doctors.length,
                    itemBuilder: (context, i) {
                      final doc = doctors[i];
                      final isSelected = _selectedIndex == i;
                      return AnimatedInteractiveContainer(
                        onTap: () {
                          setState(() => _selectedIndex = i);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorDetailScreen(doctor: doc),
                            ),
                          );
                        },
                        child: _DoctorGridCard(doc: doc, isSelected: isSelected),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// STATE-AWARE DOCTOR GRID CARD
// ─────────────────────────────────────────────────
class _DoctorGridCard extends StatelessWidget {
  final DoctorModel doc;
  final bool isSelected;
  const _DoctorGridCard({required this.doc, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isSelected ? AppColors.greenShadow : AppColors.cardShadow(),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar — HD cached photo with shimmer placeholder
          Hero(
            tag: 'doctor_profile_${doc.id}',
            child: HdAvatar(
              imageUrl: hdDoctorUrl(doc.id),
              radius: 29,
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.primary.withValues(alpha: 0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isSelected ? 0.0 : 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Name
          Text(
            doc.name,
            style: AppTextStyles.bodySemiBold(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ).copyWith(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          // Specialty
          Text(
            doc.specialty,
            style: AppTextStyles.labelSmall(
              color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Rating row + arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 13,
                          color: isSelected ? Colors.white : AppColors.star),
                      const SizedBox(width: 3),
                      Text(doc.rating.toString(),
                          style: AppTextStyles.labelBold(
                              color: isSelected ? Colors.white : AppColors.textPrimary)),
                    ],
                  ),
                  Text(
                    '73 Reviews',
                    style: AppTextStyles.labelSmall(
                        color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppColors.textMuted)
                        .copyWith(fontSize: 9),
                  ),
                ],
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.north_east_rounded,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.primary,
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

// ─────────────────────────────────────────────────
// SHIMMER SKELETON GRID — shown while loading
// ─────────────────────────────────────────────────
class _ShimmerDoctorGrid extends StatelessWidget {
  const _ShimmerDoctorGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE0EDD8),
        highlightColor: const Color(0xFFF5FAF0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 12, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 8),
              Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              const Spacer(),
              Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            ],
          ),
        ),
      ),
    );
  }
}
