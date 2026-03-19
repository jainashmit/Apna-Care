import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../doctors/domain/providers/doctor_provider.dart';
import '../../hospitals/domain/providers/hospital_provider.dart';
import '../domain/home_provider.dart';
import '../../doctors/data/models/doctor_model.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../hospitals/views/hospital_detail_screen.dart';
import '../../doctors/views/doctor_detail_screen.dart';
import 'category_selection_screen.dart';
import '../../../core/services/location_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  final List<_BannerItem> _banners = [
    const _BannerItem(
      title: 'Book Home Visits\nInstantly!',
      subtitle: 'NEW FEATURE',
      icon: '🏠',
      color: AppColors.primary,
    ),
    const _BannerItem(
      title: 'Free Health Checkup\nthis Sunday',
      subtitle: 'HEALTH CAMP',
      icon: '🩺',
      color: AppColors.secondary,
    ),
    const _BannerItem(
      title: 'Get 20% Discount\non Medicinces',
      subtitle: 'PHARMACY',
      icon: '💊',
      color: AppColors.accent,
    ),
  ];

  final List<_ServiceCategory> _services = const [
    _ServiceCategory(icon: '🏥', label: 'OPD', color: Color(0xFF1565C0)),
    _ServiceCategory(icon: '🔬', label: 'Surgery', color: Color(0xFF7B61FF)),
    _ServiceCategory(icon: '🚑', label: 'Ambulance', color: Color(0xFFE53935)),
    _ServiceCategory(icon: '💊', label: 'Medicines', color: Color(0xFFFFB300)),
  ];

  final List<_Specialist> _specialists = const [
    _Specialist(icon: '❤️', name: 'Cardiology', count: '48 doctors'),
    _Specialist(icon: '🧠', name: 'Neurology', count: '32 doctors'),
    _Specialist(icon: '👂', name: 'ENT', count: '21 doctors'),
    _Specialist(icon: '🦴', name: 'Orthopaedics', count: '37 doctors'),
    _Specialist(icon: '👶', name: 'Paediatrics', count: '44 doctors'),
    _Specialist(icon: '🌿', name: 'Skin & Hair', count: '29 doctors'),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _searchController.addListener(() {
      ref.read(homeProvider.notifier).updateSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:112');
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    ref.listen<LocationPermissionState>(locationPermissionProvider, (previous, next) {
      if (next == LocationPermissionState.permanentlyDenied && previous != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location is permanently denied. Please enable in Settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => ref.read(locationPermissionProvider.notifier).openSettings(),
            ),
          ),
        );
      } else if (next == LocationPermissionState.denied && previous != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required for nearby hospitals.')),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: GestureDetector(
        onTap: _callEmergency,
        child: GlassShadowContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          borderRadius: 30,
          color: AppColors.accent.withValues(alpha: 0.1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('SOS', style: AppTextStyles.button().copyWith(color: AppColors.accent)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(homeState.selectedNav),
      body: Stack(
        children: [
          const PremiumBackgroundBlobs(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: _buildSearchBar(homeState.isSearchFocused),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildBannerCarousel(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSection(title: 'What do you need?', child: _buildServicesGrid()),
                ),
                SliverToBoxAdapter(
                  child: _buildSection(title: 'Find by Specialist', child: _buildSpecialistRow()),
                ),
                SliverToBoxAdapter(
                  child: _buildSection(
                    title: 'Top Rated Doctors',
                    trailing: _seeAllBtn(),
                    child: _buildDoctorsRow(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSection(
                    title: 'Nearby Hospitals',
                    trailing: _seeAllBtn(),
                    child: _buildHospitalsList(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('📍', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('New Delhi, India',
                      style: AppTextStyles.labelBold(color: AppColors.primary)),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                ]),
                const SizedBox(height: 4),
                Text('Hello, Ashmit 👋', style: AppTextStyles.heading1()),
              ],
            ),
          ),
          _ModernIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Text('AJ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ───────────────────────────────────────────────
  Widget _buildSearchBar(bool isFocused) {
    return PremiumGlassCard(
      opacity: 0.25,
      blur: 20,
      borderRadius: 20,
      border: Border.all(
        color: isFocused ? AppColors.primary.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6),
        width: 1.5,
      ),
      child: TextField(
        controller: _searchController,
        onTap: () => ref.read(homeProvider.notifier).setSearchFocused(true),
        onTapOutside: (_) => ref.read(homeProvider.notifier).setSearchFocused(false),
        style: AppTextStyles.bodyMedium(),
        decoration: InputDecoration(
          hintText: 'Search doctors, hospitals...',
          hintStyle: AppTextStyles.subHeader(),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // ── BANNER SLIDER ───────────────────────────────────────────
  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _currentBannerIndex = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) {
              final banner = _banners[i];
              final gradient = [AppColors.meshGradient1, AppColors.meshGradient2, AppColors.meshGradient3][i % 3];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedInteractiveContainer(
                  onTap: () {},
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.glassShadow(),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: banner.color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(banner.subtitle, 
                                        style: AppTextStyles.labelBold(color: banner.color).copyWith(fontSize: 10, letterSpacing: 1.0)),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(banner.title, 
                                      style: AppTextStyles.heading2().copyWith(height: 1.1)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: _Floating3DIcon(
                                  child: Text(banner.icon, style: const TextStyle(fontSize: 70)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentBannerIndex == index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── SECTION WRAPPER ──────────────────────────────────────────
  Widget _buildSection({required String title, Widget? trailing, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.heading3()),
              if (trailing != null) trailing,
            ],
          ),
        ),
        child,
      ],
    );
  }

  Widget _seeAllBtn() => TextButton(
        onPressed: () {},
        child: Text('See All', style: AppTextStyles.labelBold(color: AppColors.primary)),
      );

  Widget _buildServicesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _services.map((s) {
          return AnimatedInteractiveContainer(
            onTap: () {
              if (s.label == 'Ambulance') {
                Navigator.pushNamed(context, AppRoutes.ambulance);
              } else if (s.label == 'OPD') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategorySelectionScreen()),
                );
              }
            },
            child: Column(
              children: [
                PremiumGlassCard(
                  width: 80,
                  height: 80,
                  opacity: 0.2,
                  blur: 15,
                  borderRadius: 24,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  child: Center(
                    child: _Floating3DIcon(
                      child: Text(s.icon, style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(s.label, style: AppTextStyles.bodySemiBold(color: AppColors.textPrimary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpecialistRow() {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _specialists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final sp = _specialists[i];
          return AnimatedInteractiveContainer(
            onTap: () {},
            child: PremiumGlassCard(
              width: 160,
              padding: const EdgeInsets.all(16),
              opacity: 0.2,
              borderRadius: 24,
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
              child: Row(
                children: [
                  _Floating3DIcon(
                    child: Text(sp.icon, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(sp.name, style: AppTextStyles.bodySemiBold(), maxLines: 1),
                        const SizedBox(height: 4),
                        Text(sp.count, style: AppTextStyles.labelSmall(color: AppColors.textMuted), maxLines: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── DOCTORS ROW ──────────────────────────────────────────────
  Widget _buildDoctorsRow() {
    final doctorsAsync = ref.watch(topDoctorsProvider);

    return SizedBox(
      height: 260,
      child: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (doctors) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, i) {
            final doc = doctors[i];
            return AnimatedInteractiveContainer(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorDetailScreen(doctor: doc)),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PremiumGlassCard(
                    width: 180,
                    margin: const EdgeInsets.only(top: 25),
                    padding: const EdgeInsets.fromLTRB(16, 45, 16, 16),
                    opacity: 0.2,
                    borderRadius: 28,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.name, style: AppTextStyles.bodySemiBold(), maxLines: 1),
                        const SizedBox(height: 2),
                        Text(doc.specialty, style: AppTextStyles.labelSmall(color: AppColors.textMuted), maxLines: 1),
                        const Spacer(),
                        Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 4),
                            Text(doc.rating.toString(), style: AppTextStyles.labelBold()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${doc.opdFee}', style: AppTextStyles.bodySemiBold(color: AppColors.primary)),
                            Text(doc.experience, style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 16,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.glassShadow(),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: (doc is DoctorModel && doc.imageUrl != null)
                            ? Image.network(doc.imageUrl!, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 35),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── HOSPITALS LIST ───────────────────────────────────────────
  Widget _buildHospitalsList() {
    final hospitalsAsync = ref.watch(hospitalsProvider);

    return hospitalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (hospitals) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: hospitals.take(3).map((h) {
            return AnimatedInteractiveContainer(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HospitalDetailScreen(hospital: h)),
                );
              },
              child: PremiumGlassCard(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                opacity: 0.15,
                borderRadius: 24,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.2),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: GlassShadowContainer(
                    width: 54,
                    height: 54,
                    borderRadius: 16,
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                    child: const Center(child: Text('🏨', style: TextStyle(fontSize: 24))),
                  ),
                  title: Text(h.name, style: AppTextStyles.bodySemiBold()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(h.specialties.first, style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('📍', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text('${h.distanceKm} km', style: AppTextStyles.labelSmall()),
                          const SizedBox(width: 12),
                          const Text('⭐', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(h.rating.toString(), style: AppTextStyles.labelBold()),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── BOTTOM NAV ───────────────────────────────────────────────
  Widget _buildBottomNav(int selectedNav) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: PremiumGlassCard(
        borderRadius: 30,
        opacity: 0.3,
        blur: 25,
        padding: const EdgeInsets.symmetric(vertical: 4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        child: BottomNavigationBar(
          currentIndex: selectedNav,
          onTap: (i) => ref.read(homeProvider.notifier).setNav(i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _Floating3DIcon extends StatefulWidget {
  final Widget child;
  const _Floating3DIcon({required this.child});

  @override
  State<_Floating3DIcon> createState() => _Floating3DIconState();
}

class _Floating3DIconState extends State<_Floating3DIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow for 3D effect
              Transform.translate(
                offset: Offset(0, _animation.value + 15),
                child: Container(
                  width: 30,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _BannerItem {
  final String title, subtitle, icon;
  final Color color;
  const _BannerItem({required this.title, required this.subtitle, required this.icon, required this.color});
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
        padding: const EdgeInsets.all(8),
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

class _ServiceCategory {
  final String icon, label;
  final Color color;
  const _ServiceCategory({required this.icon, required this.label, required this.color});
}

class _Specialist {
  final String icon, name, count;
  const _Specialist({required this.icon, required this.name, required this.count});
}
