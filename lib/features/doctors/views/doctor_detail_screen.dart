import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'dart:ui';
import '../data/models/doctor_model.dart';
import '../domain/providers/doctor_provider.dart';
import '../../../core/widgets/premium_widgets.dart';

class DoctorDetailScreen extends StatefulWidget {
  final DoctorModel doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  bool _isBioExpanded = false;
  int _selectedMonthIndex = 1;
  int _selectedDateIndex = 3; // For '5 Wed' in the mock
  String _selectedTime = "10:30 AM";

  final List<String> _months = ["October", "November", "December", "January", "February"];
  final List<Map<String, String>> _dates = [
    {"day": "2", "weekday": "Sun"},
    {"day": "3", "weekday": "Mon"},
    {"day": "4", "weekday": "Tue"},
    {"day": "5", "weekday": "Wed"},
    {"day": "6", "weekday": "Thu"},
    {"day": "7", "weekday": "Fri"},
    {"day": "8", "weekday": "Sat"},
  ];
  final List<String> _times = ["10:30 AM", "11:00 AM", "12:00 PM", "01:00 PM", "02:00 PM"];

  void _copyNumber(BuildContext context) {
    const dummyNumber = "+91 9876543210";
    Clipboard.setData(const ClipboardData(text: dummyNumber)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Number copied to clipboard')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const PremiumBackgroundBlobs(),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(),
                      const SizedBox(height: 40),
                      _buildAboutSection(),
                      const SizedBox(height: 40),
                      _buildDatePicker(),
                      const SizedBox(height: 40),
                      _buildTimePicker(),
                      const SizedBox(height: 40),
                      Text('Credentials', style: AppTextStyles.heading2().copyWith(fontSize: 22)),
                      const SizedBox(height: 16),
                      _buildCredentialsList(),
                      const SizedBox(height: 40),
                      Text('Associated Hospital', style: AppTextStyles.heading2().copyWith(fontSize: 22)),
                      const SizedBox(height: 12),
                      _buildHospitalCard(),
                      const SizedBox(height: 40),
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
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      title: _isBioExpanded ? Text(widget.doctor.name, style: AppTextStyles.bodySemiBold(color: Colors.white)) : null,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PremiumGlassCard(
          borderRadius: 100,
          opacity: 0.2,
          blur: 10,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PremiumGlassCard(
            borderRadius: 100,
            opacity: 0.2,
            blur: 10,
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
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
            Container(decoration: BoxDecoration(gradient: AppColors.primaryGradient)),
            
            // 3D Profile Frame
            Center(
              child: Hero(
                tag: 'doctor_profile_${widget.doctor.id}',
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: widget.doctor.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.doctor.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppColors.primaryLight,
                      ),
                      child: widget.doctor.imageUrl == null
                          ? const Icon(Icons.person_rounded, size: 80, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            
            // Name Card
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: PremiumGlassCard(
                padding: const EdgeInsets.all(20),
                opacity: 0.25,
                blur: 15,
                borderRadius: 24,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.2),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctor.name, style: AppTextStyles.heading2(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(widget.doctor.specialty, style: AppTextStyles.labelBold(color: Colors.white70)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(widget.doctor.rating.toString(), style: AppTextStyles.bodySemiBold(color: Colors.white)),
                        ],
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

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Experience', widget.doctor.experience, Icons.work_history_rounded),
        _buildStatItem('Patients', '2.8k+', Icons.groups_rounded),
        _buildStatItem('Reviews', '1.2k', Icons.reviews_rounded),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return PremiumGlassCard(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.symmetric(vertical: 20),
      opacity: 0.1,
      borderRadius: 24,
      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.bodySemiBold(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Date', style: AppTextStyles.heading2().copyWith(fontSize: 22)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Nov 2026', style: AppTextStyles.labelBold(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final isSelected = _selectedDateIndex == index;
              final date = _dates[index];
              return AnimatedInteractiveContainer(
                onTap: () => setState(() => _selectedDateIndex = index),
                child: PremiumGlassCard(
                  width: 72,
                  opacity: isSelected ? 1.0 : 0.1,
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: 22,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date['day']!,
                        style: AppTextStyles.heading2(color: isSelected ? Colors.white : AppColors.textPrimary).copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date['weekday']!.toUpperCase(),
                        style: AppTextStyles.labelBold(color: isSelected ? Colors.white70 : AppColors.textMuted).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Time', style: AppTextStyles.heading2().copyWith(fontSize: 22)),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _times.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final time = _times[index];
              final isSelected = _selectedTime == time;
              return AnimatedInteractiveContainer(
                onTap: () => setState(() => _selectedTime = time),
                child: PremiumGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  opacity: isSelected ? 1.0 : 0.1,
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: 16,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.05),
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: AppTextStyles.bodySemiBold(color: isSelected ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    final String dummyBio = "${widget.doctor.name} is a leading specialist in ${widget.doctor.specialty} with over ${widget.doctor.experience} of experience. They are highly regarded for their precision in complex procedures and their patient-centric approach to healthcare.";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Doctor', style: AppTextStyles.heading2().copyWith(fontSize: 22)),
        const SizedBox(height: 16),
        Text(
          dummyBio,
          style: AppTextStyles.bodyMedium(color: AppColors.textMuted).copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildCredentialsList() {
    final List<Map<String, String>> credentials = [
      {'title': 'Medical Degree', 'icon': '🎓'},
      {'title': 'MD Specialist', 'icon': '🩺'},
      {'title': 'Board Certified', 'icon': '🏆'},
    ];
    
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: credentials.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cred = credentials[index];
          return PremiumGlassCard(
            width: 150,
            padding: const EdgeInsets.all(16),
            opacity: 0.1,
            borderRadius: 24,
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cred['icon']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(cred['title']!, style: AppTextStyles.labelBold(), textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHospitalCard() {
    return AnimatedInteractiveContainer(
      onTap: () {},
      child: PremiumGlassCard(
        padding: const EdgeInsets.all(12),
        opacity: 0.1,
        borderRadius: 24,
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: GlassShadowContainer(
            width: 56,
            height: 56,
            borderRadius: 16,
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            child: const Center(child: Text('🏥', style: TextStyle(fontSize: 28))),
          ),
          title: Text(widget.doctor.hospitalName ?? 'Private Clinic', style: AppTextStyles.bodySemiBold()),
          subtitle: Text('Premium Care Unit', style: AppTextStyles.labelSmall(color: AppColors.textMuted)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(
                  'Book Appointment • ₹${widget.doctor.opdFee}',
                  style: AppTextStyles.button().copyWith(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
