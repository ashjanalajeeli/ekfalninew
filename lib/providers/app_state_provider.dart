import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider = StateNotifierProvider<AppStateNotifier, int>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<int> {
  AppStateNotifier() : super(0);

  void refreshApp() {
    state = state + 1; // Increment state to trigger rebuild
  }
} 