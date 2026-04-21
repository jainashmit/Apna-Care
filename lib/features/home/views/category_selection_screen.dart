import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/hd_network_image.dart';
import '../../doctors/views/doctor_list_screen.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = [
      {'id': 'orthopedics',       'name': 'Orthopedics', 'iconUrl': icons83d('human-bone')},
      {'id': 'neurology',         'name': 'Neurology',   'iconUrl': icons83d('brain')},
      {'id': 'cardiology',        'name': 'Cardiology',  'iconUrl': icons83d('heart-with-pulse')},
      {'id': 'nephrology',        'name': 'Kidney',      'iconUrl': icons83d('water-drop')},
      {'id': 'gastroenterology',  'name': 'Gastrology',  'iconUrl': icons83d('stomach')},
      {'id': 'pulmonology',       'name': 'Lungs',       'iconUrl': icons83d('lungs')},
      {'id': 'dentist',           'name': 'Dentistry',   'iconUrl': icons83d('tooth')},
      {'id': 'pediatrics',        'name': 'Pediatrics',  'iconUrl': icons83d('baby')},
      {'id': 'general_physician', 'name': 'General',     'iconUrl': icons83d('stethoscope')},
      {'id': 'dermatology',       'name': 'Dermatology', 'iconUrl': icons83d('treatment')},
      {'id': 'ent',               'name': 'ENT',         'iconUrl': icons83d('ear')},
      {'id': 'ophthalmology',     'name': 'Eye Care',    'iconUrl': icons83d('eye')},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Departments', style: AppTextStyles.heading2()),
                  ),
                  // Notification bell
                  Container(
                    width: 40,
                    height: 40,
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
                          top: 9,
                          right: 9,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Text(
                'Select a targeted specialty to browse professionals instantly.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ),

            // ── Category circular grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 24,
                  // Give each cell more height for circle + external label
                  childAspectRatio: 0.80,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _CircularCategoryItem(
                    name: cat['name'] as String,
                    iconUrl: cat['iconUrl'] as String,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorListScreen(
                            categoryId: cat['id'] as String,
                            categoryName: cat['name'] as String,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// MINIMALIST CIRCULAR GRID ITEM
// Large floating green circle, label below, scale + glow ring feedback
// ─────────────────────────────────────────────────
class _CircularCategoryItem extends StatefulWidget {
  final String name;
  final String iconUrl;
  final VoidCallback onTap;

  const _CircularCategoryItem({
    required this.name,
    required this.iconUrl,
    required this.onTap,
  });

  @override
  State<_CircularCategoryItem> createState() => _CircularCategoryItemState();
}

class _CircularCategoryItemState extends State<_CircularCategoryItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Floating circle with optional glow ring
          ScaleTransition(
            scale: _scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pressed ? const Color(0xFFB8DDA8) : const Color(0xFFCEE9C3),
                // Glow ring when pressed
                border: _pressed
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        width: 3.5,
                      )
                    : Border.all(color: Colors.transparent, width: 3.5),
                boxShadow: _pressed
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.40),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF5A9A44).withValues(alpha: 0.30),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(0xFF5A9A44).withValues(alpha: 0.10),
                          blurRadius: 4,
                          spreadRadius: -1,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.iconUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: const Color(0xFFD0E8C8),
                    highlightColor: const Color(0xFFEEF7E8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.medical_services_rounded,
                    size: 26,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // ── External label — below the circle, NOT inside any card
          const SizedBox(height: 12),
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
