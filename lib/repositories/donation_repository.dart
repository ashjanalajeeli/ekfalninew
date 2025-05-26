import 'package:http/http.dart';

import '../models/donation_model.dart';
import '../services/donation_service.dart';

class DonationRepository {
  final DonationService _donationService;

  DonationRepository({required DonationService donationService}) 
    : _donationService = donationService;

  // Get all donations
  Future<List<Donation>> getAllDonations() async {
    try {
      return await _donationService.getAllDonations();
    } catch (e) {
      return [];
    }
  }

  // Get donations by user ID
  Future<List<Donation>> getMyDonations() async {
    try {
      return await _donationService.getMyDonations();
    } catch (e) {
      return [];
    }
  }

  // Get donation categories
  Future<List<String>> getDonationCategories() async {
    try {
      return await _donationService.getDonationCategories();
    } catch (e) {
      return [];
    }
  }

  // Create a new donation
  Future<Donation> createDonation(Map<String, dynamic> donationData) async {
    try {
      return await _donationService.createDonation(donationData);
    } catch (e) {
      throw Exception('Failed to create donation: ${e.toString()}');
    }
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String status) async {
    try {
      await _donationService.updateDonationStatus(donationId, status);
    } catch (e) {
      throw Exception('Failed to update donation status: ${e.toString()}');
    }
  }

  // Get donation statistics
  Future<Map<String, dynamic>> getDonationStatistics() async {
    try {
      return await _donationService.getDonationStatistics();
    } catch (e) {
      return {};
    }
  }

  // Create payment intent
  Future<String> createPaymentIntent(String donationId, String paymentMethod) async {
    try {
      return await _donationService.createPaymentIntent(donationId, paymentMethod);
    } catch (e) {
      throw Exception('Failed to create payment intent: ${e.toString()}');
    }
  }

  // Verify payment
  Future<void> verifyPayment(String donationId, String paymentIntentId) async {
    try {
      await _donationService.verifyPayment(donationId, paymentIntentId);
    } catch (e) {
      throw Exception('Failed to verify payment: ${e.toString()}');
    }
  }

  Future<List<Donation>> getDonationsByUser(String userId) async {
    try {
      return await _donationService.getDonationsByUser(userId);
    } catch (e) {
      return [];
    }
  }

  Future<List<Donation>> getDonationsByCategory(String category) async {
    try {
      final donations = await _donationService.getAllDonations();
      return donations.where((d) => d.category == category).toList();
    } catch (e) {
      return [];
    }
  }
} 