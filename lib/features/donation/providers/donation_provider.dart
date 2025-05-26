import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/donation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../models/donation_model.dart';

part 'donation_provider.g.dart';

// Service provider
@riverpod
DonationService donationService(DonationServiceRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return DonationService(authState.token);
}

// Donation state
@immutable
class DonationState {
  final List<Donation> donations;
  final Donation? selectedDonation;
  final String? error;
  final bool isLoading;

  const DonationState({
    this.donations = const [],
    this.selectedDonation,
    this.error,
    this.isLoading = false,
  });

  // Add array access operator
  Donation operator [](int index) => donations[index];

  // Add length getter
  int get length => donations.length;

  DonationState copyWith({
    List<Donation>? donations,
    Donation? selectedDonation,
    String? error,
    bool? isLoading,
  }) {
    return DonationState(
      donations: donations ?? this.donations,
      selectedDonation: selectedDonation ?? this.selectedDonation,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Main donation provider
final donationProvider = StateNotifierProvider<DonationNotifier, DonationState>((ref) {
  final donationService = ref.watch(donationServiceProvider);
  return DonationNotifier(donationService);
});

// Donation notifier
class DonationNotifier extends StateNotifier<DonationState> {
  final DonationService _donationService;

  DonationNotifier(this._donationService) : super(const DonationState()) {
    // Load donations initially
    loadDonations();
  }

  Future<void> loadDonations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donations = await _donationService.getMyDonations();
      state = state.copyWith(
        donations: donations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> getDonationsByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donations = await _donationService.getAllDonations();
      final filteredDonations = donations.where((d) => 
        d is Map<String, dynamic> && d['category'] == category
      ).toList();
      state = state.copyWith(
        donations: filteredDonations.map((d) => Donation.fromJson(d)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> getDonationsByUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donations = await _donationService.getMyDonations();
      state = state.copyWith(
        donations: donations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createDonation(Donation donation) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _donationService.createDonation(
        amount: donation.amount,
        campaignId: donation.campaignId ?? '',
        description: donation.description,
        type: donation.type,
        additionalData: donation.toJson(),
      );
      state = state.copyWith(
        donations: [...state.donations, Donation.fromJson(response)],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateDonationStatus(String donationId, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _donationService.updateDonationStatus(donationId, status);
      state = state.copyWith(
        donations: [
          for (final donation in state.donations)
            if (donation.id == donationId)
              donation.copyWith(status: status)
            else
              donation,
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createInKindDonation({
    required String type,
    required String description,
    String? estimatedValue,
    String? campaignId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donation = await _donationService.createInKindDonation(
        type: type,
        description: description,
        estimatedValue: estimatedValue,
        campaignId: campaignId,
      );
      state = state.copyWith(
        donations: [...state.donations, Donation.fromJson(donation)],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> getDonationById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donation = await _donationService.getDonationById(id);
      state = state.copyWith(
        selectedDonation: Donation.fromJson(donation),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addFinancialDonation({
    required double amount,
    required String campaignId,
    required String paymentMethod,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donation = await _donationService.createDonation(
        amount: amount,
        campaignId: campaignId,
        description: description,
        type: 'financial',
        additionalData: {
          'paymentMethod': paymentMethod,
        },
      );
      state = state.copyWith(
        donations: [...state.donations, Donation.fromJson(donation)],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create financial donation: ${e.toString()}',
        isLoading: false,
      );
    }
  }
}