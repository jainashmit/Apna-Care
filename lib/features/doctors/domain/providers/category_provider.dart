import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the currently selected category ID for OPD (e.g., 'general_physician')
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
