import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../doctors/domain/providers/doctor_provider.dart';
import '../../hospitals/domain/providers/hospital_provider.dart';
import '../domain/home_provider.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/hd_network_image.dart';
import '../../hospitals/views/hospital_detail_screen.dart';
import '../../hospitals/views/hospital_list_screen.dart';
import '../../doctors/views/doctor_detail_screen.dart';
import 'category_selection_screen.dart';
import 'subscription_sheet.dart';
import '../../../core/services/location_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _subscriptionKey = GlobalKey();

  // ── Service Data — Icons8 3D Fluency icons via CDN
  final List<_ServiceItem> _services = [
    _ServiceItem(
      iconUrl: icons83d('stethoscope'),
      label: 'OPD',
      color: const Color(0xFF4CAF50),
      glowColor: const Color(0xFF4CAF50),
      bgGradient: const LinearGradient(
        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      fallbackIcon: Icons.medical_services_rounded,
    ),
    _ServiceItem(
      iconUrl: icons83d('hospital'),
      label: 'IPD',
      color: const Color(0xFF1E88E5),
      glowColor: const Color(0xFF1E88E5),
      bgGradient: const LinearGradient(
        colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      fallbackIcon: Icons.bed_rounded,
    ),
    _ServiceItem(
      iconUrl: icons83d('ambulance'),
      label: 'Ambulance',
      color: const Color(0xFFEF5350),
      glowColor: const Color(0xFFEF5350),
      bgGradient: const LinearGradient(
        colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      fallbackIcon: Icons.airport_shuttle_rounded,
    ),
    _ServiceItem(
      iconUrl: icons83d('pill'),
      label: 'Medicine',
      color: const Color(0xFFFF8F00),
      glowColor: const Color(0xFFFF8F00),
      bgGradient: const LinearGradient(
        colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      fallbackIcon: Icons.medication_rounded,
    ),
  ];

  // ── Banner Data
  final List<_BannerData> _banners = const [
    _BannerData(
      title: 'YOUR MODERN\nHEALTH COMPANION',
      tag: '30% OFF',
      subtitle: 'GET 30% OFF YOUR SUBSCRIPTION',
      gradient: AppColors.meshGradient1,
    ),
    _BannerData(
      title: 'FREE HEALTH CHECK\nTHIS SUNDAY',
      tag: 'FREE',
      subtitle: 'HEALTH CAMP — LIMITED SLOTS',
      gradient: AppColors.meshGradient2,
    ),
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
    _scrollController.dispose();
    super.dispose();
  }

  /// Smoothly scrolls to the subscription banner section
  void _scrollToSubscription() {
    final ctx = _subscriptionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
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
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _buildBottomNav(homeState.selectedNav),
      floatingActionButton: _SosFab(onCall: () async {
        final uri = Uri.parse('tel:112');
        if (!await launchUrl(uri)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open phone dialer')),
            );
          }
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildIntegratedHeader()),
          SliverToBoxAdapter(child: _buildSearchBar(homeState.isSearchFocused)),
          SliverToBoxAdapter(child: _buildBannerCarousel()),
          SliverToBoxAdapter(child: _buildSectionHeader('Our Services', trailingLabel: 'See All', onTap: () {})),
          SliverToBoxAdapter(child: _buildServicesRow()),
          SliverToBoxAdapter(child: _buildFindDoctorButton()),
          SliverToBoxAdapter(
            child: _buildSectionHeader('Top Rated Doctor', trailingLabel: 'See All', onTap: () {}),
          ),
          SliverToBoxAdapter(child: _buildDoctorsRow()),
          // ── Go Unlimited Banner (subscription anchor)
          SliverToBoxAdapter(
            child: SizedBox(key: _subscriptionKey, child: _buildSubscriptionBanner()),
          ),
          // ── Top Hospitals
          SliverToBoxAdapter(
            child: _buildSectionHeader('Top Hospitals', trailingLabel: 'See All', onTap: () {}),
          ),
          SliverToBoxAdapter(child: _buildHospitalsGrid()),
          // ── Post-hospitals subscription teaser
          SliverToBoxAdapter(child: _buildSubscriptionTeaser()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // INTEGRATED HEADER
  // ───────────────────────────────────────────────
  Widget _buildIntegratedHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              // Profile avatar — HD Unsplash photo, shimmer placeholder
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=100&q=85&fm=webp&fit=crop',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: const Color(0xFFD0E8C8),
                    highlightColor: const Color(0xFFEEF7E8),
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/doctors/3d/doctor_1.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ashmit Jain',
                      style: AppTextStyles.bodySemiBold(color: AppColors.textPrimary)
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(_getGreeting(), style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
                  ],
                ),
              ),
              // Notification bell
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow(opacity: 0.08),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.notifications_outlined, size: 22, color: AppColors.textPrimary),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
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
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  // ───────────────────────────────────────────────
  // SEARCH BAR
  // ───────────────────────────────────────────────
  Widget _buildSearchBar(bool isFocused) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.cardShadow(opacity: isFocused ? 0.12 : 0.06),
          border: Border.all(
            color: isFocused ? AppColors.primary : AppColors.cardBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Green location pin prefix
            Container(
              margin: const EdgeInsets.all(6),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                onTap: () => ref.read(homeProvider.notifier).setSearchFocused(true),
                onTapOutside: (_) => ref.read(homeProvider.notifier).setSearchFocused(false),
                style: AppTextStyles.bodyMedium(),
                decoration: const InputDecoration(
                  hintText: 'Search Nearest Available Doctor |',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // SECTION HEADER
  // ───────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {String? trailingLabel, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.heading3()),
          if (trailingLabel != null)
            GestureDetector(
              onTap: onTap,
              child: Text(trailingLabel, style: AppTextStyles.labelBold(color: AppColors.textMuted)),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // BANNER CAROUSEL
  // ───────────────────────────────────────────────
  Widget _buildBannerCarousel() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _currentBannerIndex = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) {
              final banner = _banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedInteractiveContainer(
                  onTap: () {},
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: banner.gradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.cardShadow(),
                    ),
                    child: Stack(
                      children: [
                        // Decorative medical cross pattern
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Opacity(
                            opacity: 0.12,
                            child: Icon(Icons.add, size: 140, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  banner.tag,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.25,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                banner.subtitle,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Stethoscope icon on right
                        Positioned(
                          right: 16,
                          bottom: 0,
                          top: 0,
                          child: Icon(
                            Icons.health_and_safety_outlined,
                            size: 88,
                            color: Colors.white.withValues(alpha: 0.3),
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerIndex == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentBannerIndex == index
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.25),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────
  // SERVICES ROW — Premium 3D icon style
  // ───────────────────────────────────────────────
  Widget _buildServicesRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _services.map((s) {
          return AnimatedInteractiveContainer(
            onTap: () {
              if (s.label == 'Ambulance') {
                Navigator.pushNamed(context, AppRoutes.ambulance);
              } else if (s.label == 'OPD') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CategorySelectionScreen()));
              } else if (s.label == 'IPD') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CategorySelectionScreen()));
              }
            },
            child: Column(
              children: [
                // Outer glow container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: s.glowColor.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: s.bgGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: s.color.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: s.iconUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: s.color.withValues(alpha: 0.15),
                          highlightColor: s.color.withValues(alpha: 0.05),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                            Icon(s.fallbackIcon, size: 32, color: s.color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  s.label,
                  style: AppTextStyles.labelBold(color: AppColors.textPrimary)
                      .copyWith(fontSize: 12, letterSpacing: 0.1),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // FIND A DOCTOR — Premium discovery card
  // ───────────────────────────────────────────────
  Widget _buildFindDoctorButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AnimatedInteractiveContainer(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CategorySelectionScreen())),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF56C15B), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.40),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative subtle blob
              Positioned(
                right: -10,
                top: -18,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                right: 60,
                bottom: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Availability badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFA5D6A7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  '24/7 Doctors Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find a Doctor',
                            style: AppTextStyles.button().copyWith(fontSize: 18, letterSpacing: 0.2),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Book your appointment in seconds',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: stacked mini doctor avatars + arrow
                    Column(
                      children: [
                        // Mini avatar cluster
                        SizedBox(
                          width: 68,
                          height: 36,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: _MiniDoctorAvatar(
                                  url: _kMiniDocUrls[0],
                                  color: const Color(0xFFB3E5FC),
                                ),
                              ),
                              Positioned(
                                left: 22,
                                child: _MiniDoctorAvatar(
                                  url: _kMiniDocUrls[1],
                                  color: const Color(0xFFC8E6C9),
                                ),
                              ),
                              Positioned(
                                left: 44,
                                child: _MiniDoctorAvatar(
                                  url: _kMiniDocUrls[2],
                                  color: const Color(0xFFF3E5F5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 18, color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // TOP RATED DOCTORS ROW
  // ───────────────────────────────────────────────
  Widget _buildDoctorsRow() {
    final doctorsAsync = ref.watch(topDoctorsProvider);
    return SizedBox(
      height: 152,
      child: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (doctors) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final doc = doctors[i];
            return AnimatedInteractiveContainer(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doc))),
              child: _DoctorHorizontalCard(doc: doc),
            );
          },
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // GO UNLIMITED SUBSCRIPTION BANNER
  // ───────────────────────────────────────────────
  Widget _buildSubscriptionBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () => showSubscriptionSheet(context),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 16, 22),
          decoration: BoxDecoration(
            gradient: AppColors.subscriptionGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.cardShadow(opacity: 0.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Go Unlimited ',
                          style: AppTextStyles.heading3(color: Colors.white)
                              .copyWith(fontSize: 20),
                        ),
                        const Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlimited doctor consultations,\nreports & more!',
                      style: AppTextStyles.labelSmall(color: Colors.white.withValues(alpha: 0.85))
                          .copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        'View Plans',
                        style: AppTextStyles.labelBold(color: AppColors.primaryDark)
                            .copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.all_inclusive_rounded,
                color: Colors.white,
                size: 72,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // TOP HOSPITALS GRID — 6 items + View All
  // ───────────────────────────────────────────────
  Widget _buildHospitalsGrid() {
    final hospitalsAsync = ref.watch(hospitalsProvider);
    return hospitalsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.76,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => _HospitalGridCardSkeleton(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (hospitals) {
        final shown = hospitals.take(6).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: shown.length,
                itemBuilder: (context, i) {
                  final h = shown[i];
                  return AnimatedInteractiveContainer(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => HospitalDetailScreen(hospital: h))),
                    child: _HospitalGridCard(hospital: h),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // View All button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HospitalListScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0FAF0), Color(0xFFE4F5E4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
                    boxShadow: AppColors.cardShadow(opacity: 0.04),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_hospital_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'View All Hospitals',
                        style: AppTextStyles.labelBold(color: AppColors.primary)
                            .copyWith(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 15, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // SUBSCRIPTION TEASER — below hospitals, taps to scroll up to Go Unlimited
  // ───────────────────────────────────────────────
  Widget _buildSubscriptionTeaser() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () {
          _scrollToSubscription();
          // Short delay then open sheet
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) showSubscriptionSheet(context);
          });
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.cardShadow(opacity: 0.05),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.greenShadow,
                ),
                child: const Center(
                  child: Icon(Icons.workspace_premium_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Premium Care',
                      style: AppTextStyles.bodySemiBold()
                          .copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Unlimited consultations, reports & priority booking.',
                      style: AppTextStyles.labelSmall(color: AppColors.textMuted)
                          .copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'View Plans',
                  style: AppTextStyles.labelBold(color: AppColors.primary)
                      .copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // BOTTOM NAV — fixed sliding indicator
  // ───────────────────────────────────────────────
  Widget _buildBottomNav(int selectedNav) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 72,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppColors.glassShadow(),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _NavItem(index: 0, icon: Icons.home_filled, label: 'Home',
                    selectedNav: selectedNav,
                    onTap: () => ref.read(homeProvider.notifier).setNav(0)),
                _NavItem(index: 1, icon: Icons.medical_services_outlined, label: 'Doctors',
                    selectedNav: selectedNav,
                    onTap: () => ref.read(homeProvider.notifier).setNav(1)),
                // Chatbot spacer
                const SizedBox(width: 64),
                _NavItem(index: 3, icon: Icons.calendar_month_outlined, label: 'Bookings',
                    selectedNav: selectedNav,
                    onTap: () => ref.read(homeProvider.notifier).setNav(3)),
                _NavItem(index: 4, icon: Icons.person_outline_rounded, label: 'Profile',
                    selectedNav: selectedNav,
                    onTap: () => ref.read(homeProvider.notifier).setNav(4)),
              ],
            ),
          ),
        ),
        // Chatbot bubble
        Positioned(
          top: -24,
          child: GestureDetector(
            onTap: () {
              ref.read(homeProvider.notifier).setNav(2);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text('AI Assistant coming soon …'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF334F33),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5CB85C), Color(0xFF2E5A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// DOCTOR HORIZONTAL CARD — tinted compact design
// ─────────────────────────────────────────────────
class _DoctorHorizontalCard extends StatelessWidget {
  final dynamic doc;
  const _DoctorHorizontalCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow(opacity: 0.07),
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FAF0), Color(0xFFE4F5E4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFCCE8CC), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar row
            Row(
              children: [
                HdAvatar(
                  imageUrl: hdDoctorUrl(doc?.id),
                  radius: 24,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doc.name,
                              style: AppTextStyles.bodySemiBold()
                                  .copyWith(fontSize: 12.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.verified_rounded,
                              size: 12, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          doc.specialty ?? 'Specialist',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.0),
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Rating + arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: AppColors.star),
                    const SizedBox(width: 3),
                    Text(
                      doc.rating.toString(),
                      style: AppTextStyles.labelBold(
                              color: AppColors.textPrimary)
                          .copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 3),
                    Text('(240)',
                        style: AppTextStyles.labelSmall(
                                color: AppColors.textMuted)
                            .copyWith(fontSize: 9.5)),
                  ],
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.north_east_rounded,
                        size: 12, color: Colors.white),
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

// ─────────────────────────────────────────────────
// HOSPITAL GRID CARD — premium design matching doctor card skeleton
// ─────────────────────────────────────────────────
class _HospitalGridCard extends StatelessWidget {
  final dynamic hospital;
  const _HospitalGridCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final hasEmergency = hospital.hasEmergency as bool;
    final specialty = (hospital.specialties as List).isNotEmpty
        ? hospital.specialties.first as String
        : 'General';
    // Accent bar color: red for emergency, green for standard
    final accentColor = hasEmergency ? const Color(0xFFEF5350) : AppColors.primary;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow(opacity: 0.07),
            border: Border.all(color: const Color(0xFFDCEEDC), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Photo header with badges
              SizedBox(
                height: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
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
                    // Bottom scrim gradient
                    Positioned(
                      bottom: 0, left: 0, right: 0, height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.52),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Emergency badge top-right
                    if (hasEmergency)
                      Positioned(
                        top: 7, right: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF5350),
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text('24/7',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    // Distance pill bottom-left on image
                    Positioned(
                      bottom: 6, left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded, size: 9, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${hospital.distanceKm} km',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info body — tinted gradient like doctor card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF0FAF0), Color(0xFFE4F5E4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specialty pill — like doctor card's specialty badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          specialty.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: hasEmergency ? const Color(0xFFEF5350) : AppColors.primaryDark,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Hospital name
                      Text(
                        hospital.name,
                        style: AppTextStyles.bodySemiBold().copyWith(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.0),
                              AppColors.primary.withValues(alpha: 0.18),
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Rating row + arrow button
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 11, color: AppColors.star),
                          const SizedBox(width: 2),
                          Text(
                            hospital.rating.toString(),
                            style: AppTextStyles.labelBold().copyWith(fontSize: 11),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${hospital.reviewCount})',
                            style: AppTextStyles.labelSmall(color: AppColors.textMuted)
                                .copyWith(fontSize: 9),
                          ),
                          const Spacer(),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: hasEmergency
                                    ? [const Color(0xFFEF5350), const Color(0xFFC62828)]
                                    : [const Color(0xFF66BB6A), const Color(0xFF388E3C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Center(
                              child: Icon(Icons.north_east_rounded, size: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// HOSPITAL GRID CARD SKELETON
// ─────────────────────────────────────────────────
class _HospitalGridCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE8F5E8),
        highlightColor: const Color(0xFFF5FAF5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 88, color: Colors.white),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 80,
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 60,
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(5))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// DATA CLASSES
// ─────────────────────────────────────────────────

// Mini doctor avatar URLs for the FindDoctor card cluster
const List<String> _kMiniDocUrls = [
  'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=80&q=80&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=80&q=80&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=80&q=80&fm=webp&fit=crop',
];

class _ServiceItem {
  final String iconUrl;
  final String label;
  final Color color;
  final Color glowColor;
  final LinearGradient bgGradient;
  final IconData fallbackIcon;
  const _ServiceItem({
    required this.iconUrl,
    required this.label,
    required this.color,
    required this.glowColor,
    required this.bgGradient,
    required this.fallbackIcon,
  });
}

/// Small circular avatar used in the Find a Doctor card cluster
class _MiniDoctorAvatar extends StatelessWidget {
  final String url;
  final Color color;
  const _MiniDoctorAvatar({required this.url, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 34,
          height: 34,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (_, __) => Container(color: color),
          errorWidget: (_, __, ___) => const Icon(
            Icons.person_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BannerData {
  final String title, tag, subtitle;
  final LinearGradient gradient;
  const _BannerData({
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.gradient,
  });
}

// ─────────────────────────────────────────────────
// NAV ITEM — self-contained nav tab with indicator
// ─────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int selectedNav;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.selectedNav,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedNav == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 72,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 52,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  scale: isSelected ? 1.15 : 1.0,
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────
// SOS FLOATING ACTION BUTTON
// ───────────────────────────────────────────────
class _SosFab extends StatelessWidget {
  final VoidCallback onCall;
  const _SosFab({required this.onCall});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCall,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [Color(0xFFEF5350), Color(0xFFC62828)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withValues(alpha: 0.40),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
            Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
