import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ─────────────────────────────────────────────────────
class HomeState {
  final int selectedNav;
  final String searchQuery;
  final bool isSearchFocused;

  const HomeState({
    this.selectedNav = 0,
    this.searchQuery = '',
    this.isSearchFocused = false,
  });

  HomeState copyWith({
    int? selectedNav,
    String? searchQuery,
    bool? isSearchFocused,
  }) {
    return HomeState(
      selectedNav: selectedNav ?? this.selectedNav,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearchFocused: isSearchFocused ?? this.isSearchFocused,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void setNav(int index) {
    state = state.copyWith(selectedNav: index);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSearchFocused(bool focused) {
    state = state.copyWith(isSearchFocused: focused);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', isSearchFocused: false);
  }
}

// ── Provider ──────────────────────────────────────────────────
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
