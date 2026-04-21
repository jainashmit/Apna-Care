import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/hd_network_image.dart';
import '../data/models/doctor_model.dart';
import '../../hospitals/views/hospital_detail_screen.dart';
import '../../hospitals/data/models/hospital_model.dart';

class DoctorDetailScreen extends StatefulWidget {
  final DoctorModel doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  // ── Dynamic date state — stores a real DateTime for API use
  late DateTime _selectedDate;
  late List<DateTime> _dateSlots;
  String? _selectedTime;

  final List<String> _times = ['10:30 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM'];

  /// Generate 7 calendar days starting from today
  List<DateTime> _generateSlots() {
    final today = DateTime.now();
    return List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));
  }

  /// Returns true if a date slot is available (mock: Tue/Thu/Sun unavailable)
  bool _isAvailable(DateTime date) => ![2, 4, 7].contains(date.weekday);

  @override
  void initState() {
    super.initState();
    _dateSlots = _generateSlots();
    // Auto-select the first available date
    _selectedDate = _dateSlots.firstWhere(
      _isAvailable,
      orElse: () => _dateSlots.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(),
                      const SizedBox(height: 36),
                      _buildAboutSection(),
                      const SizedBox(height: 36),
                      _buildDatePicker(),
                      const SizedBox(height: 36),
                      _buildTimePicker(),
                      const SizedBox(height: 36),
                      Text('Credentials', style: AppTextStyles.heading3()),
                      const SizedBox(height: 16),
                      _buildCredentialsList(),
                      const SizedBox(height: 36),
                      Text('Associated Hospital', style: AppTextStyles.heading3()),
                      const SizedBox(height: 12),
                      _buildHospitalCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBookBar(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: true,
      title: Text(
        widget.doctor.name,
        style: AppTextStyles.bodySemiBold(color: Colors.white),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const IconButton(
              icon: Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
              onPressed: null,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed doctor portrait — HD cached photo
            Hero(
              tag: 'doctor_profile_${widget.doctor.id}',
              child: CachedNetworkImage(
                imageUrl: hdDoctorUrl(widget.doctor.id),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: const Color(0xFF2E7D32),
                  highlightColor: const Color(0xFF388E3C),
                  child: Container(color: AppColors.primaryDark),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primaryDark,
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom gradient overlay for text legibility
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.80),
                      Colors.black.withValues(alpha: 0.40),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Top vignette for nav bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Name + specialty + rating at bottom
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Specialty badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.doctor.specialty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          widget.doctor.name,
                          style: AppTextStyles.heading2(color: Colors.white)
                              .copyWith(fontSize: 22, height: 1.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rating pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: AppColors.star),
                            const SizedBox(width: 4),
                            Text(
                              widget.doctor.rating.toString(),
                              style: AppTextStyles.bodySemiBold(color: Colors.white)
                                  .copyWith(fontSize: 13),
                            ),
                          ],
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
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatChip('Experience', widget.doctor.experience, Icons.work_history_rounded),
        _buildStatChip('Patients', '2.8k+', Icons.groups_rounded),
        _buildStatChip('Reviews', '1.2k', Icons.star_rounded),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    final w = (MediaQuery.of(context).size.width - 64) / 3;
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow(opacity: 0.06),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.bodySemiBold()),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final bio =
        '${widget.doctor.name} is a leading specialist in ${widget.doctor.specialty} with over ${widget.doctor.experience} of experience. They are highly regarded for their precision and patient-centric approach to healthcare.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Doctor', style: AppTextStyles.heading3()),
        const SizedBox(height: 12),
        Text(
          bio,
          style: AppTextStyles.bodyMedium(color: AppColors.textMuted).copyWith(height: 1.6),
        ),
      ],
    );
  }

  // ── Part 2: Dynamic date picker ─────────────────────────────────────────────
  Widget _buildDatePicker() {
    // Month label derived from first slot's month
    final monthLabel = _monthName(_dateSlots.first.month);
    final yearLabel = '${_dateSlots.first.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Date', style: AppTextStyles.heading3()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    '$monthLabel $yearLabel',
                    style: AppTextStyles.labelBold(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dateSlots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = _dateSlots[index];
              final isSelected = _isSameDay(_selectedDate, date);
              final available = _isAvailable(date);
              final isToday = _isSameDay(date, DateTime.now());
              return RepaintBoundary(
                child: _DateChip(
                  date: date,
                  isSelected: isSelected,
                  isAvailable: available,
                  isToday: isToday,
                  onTap: available
                      ? () => setState(() => _selectedDate = date)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month];
  }

  // ── Part 3: Optimized time picker with scoped rebuilds ──────────────────────
  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Available Time', style: AppTextStyles.heading3()),
            const Spacer(),
            Text(
              '${_times.length} slots',
              style: AppTextStyles.labelSmall(color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _times.map((time) {
            return _TimeChip(
              time: time,
              isSelected: _selectedTime == time,
              onTap: () => setState(() => _selectedTime = time),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCredentialsList() {
    final creds = [
      {'title': 'Medical Degree', 'icon': Icons.school_outlined},
      {'title': 'MD Specialist', 'icon': Icons.medical_services_outlined},
      {'title': 'Board Certified', 'icon': Icons.verified_outlined},
    ];
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: creds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cred = creds[index];
          return Container(
            width: 140,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.cardShadow(opacity: 0.05),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cred['icon'] as IconData, size: 22, color: AppColors.primary),
                const SizedBox(height: 6),
                Text(cred['title'] as String,
                    style: AppTextStyles.labelBold(), textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Part 3: Hospital card with navigation ───────────────────────────────────
  Widget _buildHospitalCard() {
    final hospitalName = widget.doctor.hospitalName ?? 'Private Clinic';

    // Build a mock HospitalModel from the doctor's associated hospital
    final mockHospital = HospitalModel(
      id: 'dr_hospital_${widget.doctor.id}',
      name: hospitalName,
      rating: 4.5,
      reviewCount: 320,
      distanceKm: widget.doctor.distanceKm ?? 2.5,
      specialties: [widget.doctor.specialty, 'OPD'],
      address: 'Premium Care Unit, New Delhi',
      hasEmergency: true,
      hasAmbulance: true,
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HospitalDetailScreen(hospital: mockHospital)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow(opacity: 0.05),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Hospital photo thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: hdHospitalUrl(hospitalName),
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: const Color(0xFFDCEFDC),
                  highlightColor: const Color(0xFFF2FAF2),
                  child: Container(width: 54, height: 54, color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 54,
                  height: 54,
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(Icons.local_hospital_outlined, size: 26, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospitalName,
                    style: AppTextStyles.bodySemiBold(),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        'Premium Care Unit',
                        style: AppTextStyles.labelSmall(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 11, color: AppColors.star),
                      const SizedBox(width: 3),
                      Text('4.5', style: AppTextStyles.labelBold().copyWith(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBookBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppColors.greenShadow,
            ),
            child: Center(
              child: Text(
                'Book Appointment  •  ₹${widget.doctor.opdFee}',
                style: AppTextStyles.button().copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// DATE CHIP — sharp, premium animated chip
// ─────────────────────────────────────────────────
class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isAvailable;
  final bool isToday;
  final VoidCallback? onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.isAvailable,
    required this.isToday,
    this.onTap,
  });

  static const _weekdays = ['', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 58,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected
              ? null
              : isToday
                  ? const Color(0xFFF0FAF0)
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isToday
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : isAvailable
                        ? AppColors.cardBorder
                        : AppColors.cardBorder.withValues(alpha: 0.4),
            width: isToday && !isSelected ? 1.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.42),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                ]
              : AppColors.cardShadow(opacity: 0.04),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Weekday label
              Text(
                _weekdays[date.weekday],
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.80)
                      : isToday
                          ? AppColors.primary
                          : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              // Day number
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              // Today indicator / availability dot
              if (isToday && !isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.6)
                        : isAvailable
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : Colors.transparent,
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
// TIME CHIP — self-contained widget scoping rebuilds,
// smooth TweenAnimationBuilder for gradient transition
// ─────────────────────────────────────────────────
class _TimeChip extends StatefulWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TimeChip> createState() => _TimeChipState();
}

class _TimeChipState extends State<_TimeChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: widget.isSelected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        builder: (context, value, _) {
          // Interpolate each gradient stop — this fills the ENTIRE chip background
          final colorStart = Color.lerp(Colors.white, const Color(0xFF66BB6A), value)!;
          final colorEnd   = Color.lerp(Colors.white, const Color(0xFF2E7D32), value)!;
          final textColor  = Color.lerp(AppColors.textSecondary, Colors.white, value)!;
          final borderColor = Color.lerp(AppColors.cardBorder, Colors.transparent, value)!;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorStart, colorEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.38 * value),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value > 0.4) ...[
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: value),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  widget.time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: value > 0.5 ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
