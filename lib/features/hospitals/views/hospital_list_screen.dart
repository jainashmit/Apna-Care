import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/hospital_model.dart';
import 'hospital_detail_screen.dart';

// ── Hardcoded extended hospital list (25 items) ──────────────────────────────
final List<HospitalModel> _allHospitals = [
  HospitalModel(id: 'h1', name: 'Apollo Clinic', rating: 4.8, reviewCount: 312, distanceKm: 1.2, specialties: const ['Multi-specialty', 'OPD', 'Surgery'], address: 'Saket, New Delhi – 110017', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h2', name: 'Fortis Hospital', rating: 4.6, reviewCount: 287, distanceKm: 2.7, specialties: const ['Cardiology', 'Surgery'], address: 'Vasant Kunj, New Delhi – 110070', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h3', name: 'Medanta', rating: 4.9, reviewCount: 501, distanceKm: 4.0, specialties: const ['Neurology', 'Orthopaedics', 'ENT'], address: 'Gurugram, Haryana – 122001', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h4', name: 'Max Super Speciality', rating: 4.5, reviewCount: 198, distanceKm: 3.5, specialties: const ['OPD', 'Paediatrics'], address: 'Patparganj, New Delhi – 110092', hasEmergency: false, hasAmbulance: false),
  HospitalModel(id: 'h5', name: 'AIIMS Delhi', rating: 4.9, reviewCount: 1024, distanceKm: 6.1, specialties: const ['Multi-specialty', 'Research', 'Surgery'], address: 'Ansari Nagar, New Delhi – 110029', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h6', name: 'BLK Super Speciality', rating: 4.7, reviewCount: 435, distanceKm: 3.2, specialties: const ['Oncology', 'Cardiology'], address: 'Pusa Road, New Delhi – 110005', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h7', name: 'Safdarjung Hospital', rating: 4.3, reviewCount: 756, distanceKm: 5.4, specialties: const ['General Medicine', 'Surgery', 'OPD'], address: 'Safdarjung, New Delhi – 110029', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h8', name: 'Rockland Hospital', rating: 4.4, reviewCount: 163, distanceKm: 2.1, specialties: const ['Gynaecology', 'Orthopaedics', 'Dermatology'], address: 'Qutab Institutional Area, New Delhi – 110016', hasEmergency: false, hasAmbulance: true),
  HospitalModel(id: 'h9', name: 'Sir Ganga Ram Hospital', rating: 4.8, reviewCount: 612, distanceKm: 4.8, specialties: const ['Nephrology', 'Urology', 'Gastroenterology'], address: 'Rajinder Nagar, New Delhi – 110060', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h10', name: 'Indraprastha Apollo', rating: 4.7, reviewCount: 892, distanceKm: 7.3, specialties: const ['Multi-specialty', 'Transplant', 'Neurology'], address: 'Sarita Vihar, New Delhi – 110076', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h11', name: 'Moolchand Hospital', rating: 4.5, reviewCount: 344, distanceKm: 2.9, specialties: const ['Dermatology', 'ENT', 'Orthopaedics'], address: 'Lajpat Nagar, New Delhi – 110024', hasEmergency: true, hasAmbulance: false),
  HospitalModel(id: 'h12', name: 'Holy Family Hospital', rating: 4.4, reviewCount: 271, distanceKm: 3.8, specialties: const ['Paediatrics', 'Gynaecology', 'Surgery'], address: 'Okhla Road, New Delhi – 110025', hasEmergency: false, hasAmbulance: true),
  HospitalModel(id: 'h13', name: 'Venkateshwar Hospital', rating: 4.3, reviewCount: 188, distanceKm: 5.9, specialties: const ['Cardiology', 'Surgery', 'OPD'], address: 'Dwarka, New Delhi – 110045', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h14', name: 'Columbia Asia Hospital', rating: 4.6, reviewCount: 305, distanceKm: 4.2, specialties: const ['Oncology', 'Neurology'], address: 'Palam Vihar, Gurugram – 122017', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h15', name: 'Aakash Healthcare', rating: 4.2, reviewCount: 142, distanceKm: 6.6, specialties: const ['General Medicine', 'Dermatology'], address: 'Dwarka Sector 10, New Delhi – 110075', hasEmergency: false, hasAmbulance: false),
  HospitalModel(id: 'h16', name: 'Primus Super Specialty', rating: 4.5, reviewCount: 219, distanceKm: 3.1, specialties: const ['Gastroenterology', 'Transplant'], address: 'Chandragupta Marg, New Delhi – 110021', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h17', name: 'Dharamshila Narayana', rating: 4.7, reviewCount: 558, distanceKm: 8.2, specialties: const ['Oncology', 'Research'], address: 'Vasundhara Enclave, New Delhi – 110096', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h18', name: 'Batra Hospital', rating: 4.3, reviewCount: 400, distanceKm: 4.5, specialties: const ['ENT', 'Urology', 'OPD'], address: 'Tughlakabad, New Delhi – 110062', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h19', name: 'Park Hospital', rating: 4.2, reviewCount: 115, distanceKm: 2.4, specialties: const ['Paediatrics', 'Gynaecology'], address: 'Gurugram Sector 47 – 122018', hasEmergency: false, hasAmbulance: false),
  HospitalModel(id: 'h20', name: 'Metro Hospital', rating: 4.4, reviewCount: 237, distanceKm: 3.6, specialties: const ['Orthopaedics', 'Surgery', 'Cardiology'], address: 'Faridabad, Haryana – 121013', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h21', name: 'Kailash Hospital', rating: 4.1, reviewCount: 98, distanceKm: 9.0, specialties: const ['General Medicine', 'Nephrology'], address: 'Greater Noida – 201310', hasEmergency: false, hasAmbulance: true),
  HospitalModel(id: 'h22', name: 'QRG Hospital', rating: 4.3, reviewCount: 174, distanceKm: 7.8, specialties: const ['Multi-specialty', 'Surgery'], address: 'Faridabad, Haryana – 121001', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h23', name: 'Paras Hospital', rating: 4.5, reviewCount: 323, distanceKm: 5.5, specialties: const ['Neurology', 'Cardiology', 'OPD'], address: 'Gurugram Sector 43 – 122009', hasEmergency: true, hasAmbulance: true),
  HospitalModel(id: 'h24', name: 'W Pratiksha Hospital', rating: 4.4, reviewCount: 189, distanceKm: 6.3, specialties: const ['Gynaecology', 'Paediatrics', 'Transplant'], address: 'Gurugram Sector 56 – 122011', hasEmergency: false, hasAmbulance: false),
  HospitalModel(id: 'h25', name: 'Shanti Mukand Hospital', rating: 4.2, reviewCount: 154, distanceKm: 5.0, specialties: const ['Dermatology', 'ENT', 'Orthopaedics'], address: 'Vikas Marg, New Delhi – 110092', hasEmergency: true, hasAmbulance: true),
];

const List<String> _allDepartments = [
  'All',
  'Cardiology',
  'Neurology',
  'Orthopaedics',
  'Oncology',
  'Paediatrics',
  'Gynaecology',
  'Dermatology',
  'ENT',
  'Surgery',
  'OPD',
  'General Medicine',
  'Gastroenterology',
  'Nephrology',
  'Urology',
  'Transplant',
  'Research',
  'Multi-specialty',
];

String _hdHospitalUrl(String name) {
  final encoded = Uri.encodeComponent(name);
  return 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400&q=80&fm=webp&fit=crop&sig=$encoded';
}

// ─────────────────────────────────────────────────────────────────────────────
// HOSPITAL LIST SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedSort = 'Nearest';
  bool _emergencyOnly = false;
  bool _ambulanceOnly = false;

  final List<String> _sortOptions = ['Nearest', 'Top Rated', 'Most Reviewed'];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HospitalModel> get _filtered {
    var list = _allHospitals.where((h) {
      final matchName = h.name.toLowerCase().contains(_searchQuery);
      final matchDept = _selectedDept == 'All' ||
          h.specialties.any((s) => s.toLowerCase().contains(_selectedDept.toLowerCase()));
      final matchEmergency = !_emergencyOnly || h.hasEmergency;
      final matchAmbulance = !_ambulanceOnly || h.hasAmbulance;
      return matchName && matchDept && matchEmergency && matchAmbulance;
    }).toList();

    switch (_selectedSort) {
      case 'Top Rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Most Reviewed':
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      default:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(innerBoxIsScrolled),
        ],
        body: Column(
          children: [
            // ── Dept filter chips
            _buildDeptChips(),
            // ── Toggle filters + sort
            _buildToggleBar(),
            // ── Result count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} hospitals found',
                    style: AppTextStyles.labelSmall(color: AppColors.textMuted)
                        .copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  // Sort button
                  _SortButton(
                    selected: _selectedSort,
                    options: _sortOptions,
                    onChanged: (v) => setState(() => _selectedSort = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // ── Hospital list
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _HospitalListCard(
                          hospital: filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HospitalDetailScreen(hospital: filtered[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool innerScrolled) {
    return SliverAppBar(
      pinned: true,
      elevation: innerScrolled ? 2 : 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppColors.cardShadow(opacity: 0.06),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Hospitals', style: AppTextStyles.heading2()),
          Text('Delhi NCR & surrounding areas',
              style: AppTextStyles.labelSmall(color: AppColors.textMuted)
                  .copyWith(fontSize: 10.5)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _SearchBar(controller: _searchController),
        ),
      ),
    );
  }

  Widget _buildDeptChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _allDepartments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final dept = _allDepartments[i];
          final isSelected = _selectedDept == dept;
          return GestureDetector(
            onTap: () => setState(() => _selectedDept = dept),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBorder,
                  width: isSelected ? 0 : 1,
                ),
                boxShadow: isSelected ? AppColors.greenShadow : null,
              ),
              child: Text(
                dept,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          _ToggleChip(
            label: '24/7 Emergency',
            icon: Icons.emergency_rounded,
            color: const Color(0xFFEF5350),
            active: _emergencyOnly,
            onTap: () => setState(() => _emergencyOnly = !_emergencyOnly),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'Ambulance',
            icon: Icons.airport_shuttle_rounded,
            color: const Color(0xFF1E88E5),
            active: _ambulanceOnly,
            onTap: () => setState(() => _ambulanceOnly = !_ambulanceOnly),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.search_off_rounded,
                  size: 36, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text('No hospitals found',
              style: AppTextStyles.heading3()),
          const SizedBox(height: 6),
          Text('Try different filters or search terms',
              style: AppTextStyles.subHeader()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow(opacity: 0.04),
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.bodyMedium().copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search hospitals, specialties…',
          hintStyle: AppTextStyles.labelSmall(color: AppColors.textMuted)
              .copyWith(fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 18, color: AppColors.textMuted),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: controller.clear,
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// TOGGLE CHIP
// ─────────────────────────────────────────────────
class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label,
      required this.icon,
      required this.color,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? color : AppColors.cardBorder,
              width: active ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: active ? color : AppColors.textMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? color : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// SORT BUTTON
// ─────────────────────────────────────────────────
class _SortButton extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SortButton(
      {required this.selected,
      required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => _SortSheet(options: options, selected: selected),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(selected,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
            const SizedBox(width: 3),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 13, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final List<String> options;
  final String selected;
  const _SortSheet({required this.options, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE5DD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Sort By', style: AppTextStyles.heading3()),
          const SizedBox(height: 12),
          ...options.map((o) => GestureDetector(
                onTap: () => Navigator.pop(context, o),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: o == selected
                        ? AppColors.primaryLight
                        : const Color(0xFFF8FFF8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: o == selected
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(o,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: o == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: o == selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          )),
                      const Spacer(),
                      if (o == selected)
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// HOSPITAL LIST CARD — premium list design
// ─────────────────────────────────────────────────
class _HospitalListCard extends StatelessWidget {
  final HospitalModel hospital;
  final VoidCallback onTap;
  const _HospitalListCard({required this.hospital, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow(opacity: 0.06),
          border: Border.all(color: const Color(0xFFE4EFE4), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: _hdHospitalUrl(hospital.name),
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: const Color(0xFFDCEFDC),
                  highlightColor: const Color(0xFFF2FAF2),
                  child: Container(width: 100, color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  color: const Color(0xFFCEE9C3),
                  child: const Center(
                    child: Icon(Icons.local_hospital_rounded,
                        size: 32, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + emergency badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hospital.name,
                            style: AppTextStyles.bodySemiBold()
                                .copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hospital.hasEmergency) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFEF5350)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              '24/7',
                              style: TextStyle(
                                color: Color(0xFFEF5350),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Address
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hospital.address,
                            style: AppTextStyles.labelSmall(
                                    color: AppColors.textMuted)
                                .copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Specialties chips (max 2)
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: hospital.specialties.take(2).map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s,
                            style: AppTextStyles.labelSmall(
                                    color: AppColors.primaryDark)
                                .copyWith(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Rating + distance + arrow
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: AppColors.star),
                        const SizedBox(width: 3),
                        Text(
                          hospital.rating.toStringAsFixed(1),
                          style: AppTextStyles.labelBold()
                              .copyWith(fontSize: 12),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${hospital.reviewCount})',
                          style: AppTextStyles.labelSmall(
                                  color: AppColors.textMuted)
                              .copyWith(fontSize: 10),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted
                                .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.route_rounded,
                            size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          '${hospital.distanceKm.toStringAsFixed(1)} km',
                          style: AppTextStyles.labelSmall(
                                  color: AppColors.textMuted)
                              .copyWith(fontSize: 10.5),
                        ),
                        const Spacer(),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: AppColors.primary),
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
    );
  }
}
