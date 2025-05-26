import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/sponsor_service.dart';

part 'sponsor_provider.g.dart';

// Service provider
@riverpod
SponsorService sponsorService(SponsorServiceRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return SponsorService(authState.token);
}

// Sponsor state
@immutable
class SponsorState {
  final List<Map<String, dynamic>> sponsorships;
  final List<Map<String, dynamic>> availableOrphans;
  final Map<String, dynamic>? selectedSponsorship;
  final String? error;
  final bool isLoading;

  const SponsorState({
    this.sponsorships = const [],
    this.availableOrphans = const [],
    this.selectedSponsorship,
    this.error,
    this.isLoading = false,
  });

  SponsorState copyWith({
    List<Map<String, dynamic>>? sponsorships,
    List<Map<String, dynamic>>? availableOrphans,
    Map<String, dynamic>? selectedSponsorship,
    String? error,
    bool? isLoading,
  }) {
    return SponsorState(
      sponsorships: sponsorships ?? this.sponsorships,
      availableOrphans: availableOrphans ?? this.availableOrphans,
      selectedSponsorship: selectedSponsorship ?? this.selectedSponsorship,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Sponsor notifier
@riverpod
class SponsorNotifier extends _$SponsorNotifier {
  late final SponsorService _sponsorService;

  @override
  SponsorState build() {
    _sponsorService = ref.watch(sponsorServiceProvider);
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated && next.isAuthenticated) {
        loadSponsorships();
      }
    });
    return const SponsorState();
  }

  Future<void> loadSponsorships() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sponsorships = await _sponsorService.getUserSponsorships();
      state = state.copyWith(
        sponsorships: sponsorships,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchAvailableOrphans() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orphans = await _sponsorService.getAvailableOrphans();
      
      state = state.copyWith(
        availableOrphans: orphans,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createSponsorship({
    required String orphanId,
    required int duration,
    required double amount,
    required String frequency,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sponsorship = await _sponsorService.createSponsorship(
        orphanId: orphanId,
        duration: duration,
        amount: amount,
        frequency: frequency,
        notes: notes,
      );
      
      final updatedSponsorships = [...state.sponsorships, sponsorship];
      state = state.copyWith(
        sponsorships: updatedSponsorships,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchSponsorshipById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sponsorship = await _sponsorService.getSponsorshipById(id);
      
      state = state.copyWith(
        selectedSponsorship: sponsorship,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addNewSponsorship({
    required String orphanId,
    required String amount,
    required int duration,
    required String frequency,
  }) async {
    await createSponsorship(
      orphanId: orphanId,
      amount: double.parse(amount),
      duration: duration,
      frequency: frequency,
    );
  }

  Future<void> addSponsorshipRenewal({
    required String orphanId,
    required String amount,
    required int duration,
    required String frequency,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final existingSponsorship = state.sponsorships.firstWhere(
        (s) => s['orphanId'] == orphanId,
      );

      final response = await _sponsorService.renewSponsorship(
        sponsorshipId: existingSponsorship['id'],
        amount: double.parse(amount),
        duration: duration,
        frequency: frequency,
      );

      final updatedSponsorships = state.sponsorships.map((s) => 
        s['id'] == existingSponsorship['id'] ? response as Map<String, dynamic> : s
      ).toList();

      state = state.copyWith(
        sponsorships: updatedSponsorships,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void fetchUserSponsorships() {}
} 