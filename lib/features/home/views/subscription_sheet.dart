import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Displays the subscription bottom sheet matching the reference design.
void showSubscriptionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SubscriptionSheet(),
  );
}

class _SubscriptionSheet extends StatefulWidget {
  const _SubscriptionSheet();

  @override
  State<_SubscriptionSheet> createState() => _SubscriptionSheetState();
}

class _SubscriptionSheetState extends State<_SubscriptionSheet> {
  String _selectedPlan = 'unlimited'; // 'starter' | 'unlimited'
  String _selectedBilling = 'yearly'; // 'monthly' | 'yearly'

  final Map<String, Map<String, dynamic>> _plans = {
    'starter': {
      'label':    'Starter',
      'monthly':  99.00,
      'yearly':   899.00,
      'perMonth': 75.00,
      'saving':   null,
    },
    'unlimited': {
      'label':    'Unlimited',
      'monthly':  199.00,
      'yearly':   1799.00,
      'perMonth': 150.00,
      'saving':   '25%',
    },
  };

  @override
  Widget build(BuildContext context) {
    final plan    = _plans[_selectedPlan]!;
    final isYearly = _selectedBilling == 'yearly';
    final price   = isYearly ? plan['yearly'] as double : plan['monthly'] as double;
    final perMonth = plan['perMonth'] as double;
    final saving  = plan['saving'] as String?;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── "SPECIAL OFFER" tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SPECIAL OFFER',
                          style: AppTextStyles.labelBold(color: AppColors.primary)
                              .copyWith(letterSpacing: 1.5, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Title
                      Text('Care Circle Plus', style: AppTextStyles.heading1()),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Showcase preview · payments are not connected yet',
                          style: AppTextStyles.labelBold(color: AppColors.accent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Keep your family’s care, records and\nreminders connected in one place.',
                        style: AppTextStyles.subHeader().copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // ── Plan selector: Starter / Unlimited tabs
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Choose a plan for your Care Circle',
                              style: AppTextStyles.bodyMedium()),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: _plans.entries.map((entry) {
                                final isSelected = _selectedPlan == entry.key;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedPlan = entry.key),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                      child: Center(
                                        child: Text(
                                          entry.value['label'] as String,
                                          style: AppTextStyles.labelBold(
                                            color: isSelected ? Colors.white : AppColors.textMuted,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Plan card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppColors.cardShadow(opacity: 0.05),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            // Plan name row with infinity icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.all_inclusive_rounded,
                                      color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _plans[_selectedPlan]!['label'] as String,
                                  style: AppTextStyles.heading3().copyWith(fontSize: 22),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Family care coordination, built around you',
                              style: AppTextStyles.labelSmall(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 20),

                            // ── Billing toggle: Monthly / Yearly
                            Row(
                              children: [
                                Expanded(child: _BillingCard(
                                  label: '1 month',
                                  price: '\$${plan['monthly'].toStringAsFixed(2)}',
                                  sub: '\$${plan['monthly'].toStringAsFixed(2)} /mon',
                                  isSelected: _selectedBilling == 'monthly',
                                  savingTag: null,
                                  onTap: () => setState(() => _selectedBilling = 'monthly'),
                                )),
                                const SizedBox(width: 14),
                                Expanded(child: _BillingCard(
                                  label: '1 year',
                                  price: '\$${plan['yearly'].toStringAsFixed(2)}',
                                  sub: '\$${perMonth.toStringAsFixed(2)} /mon',
                                  isSelected: _selectedBilling == 'yearly',
                                  savingTag: saving,
                                  onTap: () => setState(() => _selectedBilling = 'yearly'),
                                )),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Recurring billing, cancel anytime. Save 25%\nwith Yearly plan compared to Monthly.',
                              style: AppTextStyles.labelSmall(color: AppColors.textMuted)
                                  .copyWith(height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Subscribe button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Subscribed to ${_plans[_selectedPlan]!['label']} – ${isYearly ? 'Yearly' : 'Monthly'}!'),
                          ));
                        },
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: AppColors.greenShadow,
                          ),
                          child: Center(
                            child: Text(
                              'Subscribe Now  •  \$${price.toStringAsFixed(2)}',
                              style: AppTextStyles.button().copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Footer links
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Terms & Conditions  &  Privacy Policy apply.',
                          style: AppTextStyles.labelBold(color: AppColors.textSecondary)
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────
// BILLING OPTION CARD (Monthly / Yearly)
// ─────────────────────────────────────────────────
class _BillingCard extends StatelessWidget {
  final String label;
  final String price;
  final String sub;
  final bool isSelected;
  final String? savingTag;
  final VoidCallback onTap;

  const _BillingCard({
    required this.label,
    required this.price,
    required this.sub,
    required this.isSelected,
    required this.savingTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.label(color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Text(price,
                    style: AppTextStyles.heading3()
                        .copyWith(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sub,
                    style: AppTextStyles.labelBold(
                            color: isSelected ? Colors.white : AppColors.textMuted)
                        .copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
            if (savingTag != null && isSelected)
              Positioned(
                top: -24,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Save $savingTag',
                    style: AppTextStyles.labelBold(color: Colors.white).copyWith(fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
