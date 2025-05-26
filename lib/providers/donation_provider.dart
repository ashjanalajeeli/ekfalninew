import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/donation_model.dart';
import '../repositories/donation_repository.dart';
import '../services/donation_service.dart';

part 'donation_provider.g.dart';

@riverpod
DonationService donationService(DonationServiceRef ref) {
  return DonationService();
}

@riverpod
class DonationList extends _$DonationList {
  @override
  Future<List<Donation>> build() async {
    return _getDonations();
  }

  Future<List<Donation>> _getDonations() async {
    final service = ref.read(donationServiceProvider);
    final repository = DonationRepository(donationService: service);
    return repository.getAllDonations();
  }

  Future<void> createDonation(Donation donation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(donationServiceProvider);
      final repository = DonationRepository(donationService: service);
      await repository.createDonation(donation.toJson());
      return _getDonations();
    });
  }

  Future<void> updateDonationStatus(String donationId, String status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(donationServiceProvider);
      final repository = DonationRepository(donationService: service);
      await repository.updateDonationStatus(donationId, status);
      return _getDonations();
    });
  }
}

@riverpod
class UserDonations extends _$UserDonations {
  @override
  Future<List<Donation>> build(String userId) async {
    final service = ref.read(donationServiceProvider);
    final repository = DonationRepository(donationService: service);
    return repository.getDonationsByUser(userId);
  }
}

@riverpod
class CategoryDonations extends _$CategoryDonations {
  @override
  Future<List<Donation>> build(String category) async {
    final service = ref.read(donationServiceProvider);
    final repository = DonationRepository(donationService: service);
    return repository.getDonationsByCategory(category);
  }
}

@riverpod
class DonationStatistics extends _$DonationStatistics {
  @override
  Future<Map<String, dynamic>> build() async {
    final service = ref.read(donationServiceProvider);
    final repository = DonationRepository(donationService: service);
    return repository.getDonationStatistics();
  }
}

// Provider for current donation form state
@riverpod
class DonationForm extends _$DonationForm {
  @override
  Map<String, dynamic> build() {
    return {
      'amount': 0.0,
      'currency': 'SR',
      'donationType': 'one-time',
      'category': '',
      'paymentMethod': null,
    };
  }

  void updateAmount(double amount) {
    state = {...state, 'amount': amount};
  }

  void updateCurrency(String currency) {
    state = {...state, 'currency': currency};
  }

  void updateDonationType(String type) {
    state = {...state, 'donationType': type};
  }

  void updateCategory(String category) {
    state = {...state, 'category': category};
  }

  void updatePaymentMethod(String method) {
    state = {...state, 'paymentMethod': method};
  }

  void resetForm() {
    state = build();
  }
} 