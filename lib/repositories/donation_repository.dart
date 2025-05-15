import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/donation_model.dart';

class DonationRepository {
  static const String _donationsKey = 'donations';

  // Get all donations
  Future<List<Donation>> getAllDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final donationsJson = prefs.getStringList(_donationsKey) ?? [];
    return donationsJson
        .map((json) => Donation.fromJson(jsonDecode(json)))
        .toList();
  }

  // Get donations by user ID
  Future<List<Donation>> getDonationsByUser(String userId) async {
    final donations = await getAllDonations();
    return donations.where((donation) => donation.donorId == userId).toList();
  }

  // Get donations by category
  Future<List<Donation>> getDonationsByCategory(String category) async {
    final donations = await getAllDonations();
    return donations.where((donation) => donation.category == category).toList();
  }

  // Create a new donation
  Future<void> createDonation(Donation donation) async {
    final prefs = await SharedPreferences.getInstance();
    final donations = await getAllDonations();
    donations.add(donation);
    
    await prefs.setStringList(
      _donationsKey,
      donations.map((d) => jsonEncode(d.toJson())).toList(),
    );
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final donations = await getAllDonations();
    
    final index = donations.indexWhere((d) => d.id == donationId);
    if (index != -1) {
      donations[index] = donations[index].copyWith(status: status);
      await prefs.setStringList(
        _donationsKey,
        donations.map((d) => jsonEncode(d.toJson())).toList(),
      );
    }
  }

  // Get donation statistics
  Future<Map<String, dynamic>> getDonationStatistics() async {
    final donations = await getAllDonations();
    
    return {
      'totalAmount': donations.fold(0.0, (sum, donation) => sum + donation.amount),
      'totalDonations': donations.length,
      'completedDonations': donations.where((d) => d.status == 'completed').length,
      'pendingDonations': donations.where((d) => d.status == 'pending').length,
      'categoryBreakdown': _getCategoryBreakdown(donations),
    };
  }

  Map<String, int> _getCategoryBreakdown(List<Donation> donations) {
    final breakdown = <String, int>{};
    for (final donation in donations) {
      breakdown[donation.category] = (breakdown[donation.category] ?? 0) + 1;
    }
    return breakdown;
  }
} 