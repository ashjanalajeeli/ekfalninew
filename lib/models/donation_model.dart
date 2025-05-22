import 'package:flutter/foundation.dart';

@immutable
class Donation {
  final String id;
  final double amount;
  final String currency;
  final String donationType; // 'one-time', 'monthly', or 'project'
  final String category; // 'food', 'clothes', 'school', 'project', etc.
  final String donorId;
  final String donorName;
  final DateTime createdAt;
  final String status; // 'pending', 'completed', 'failed'
  final String? paymentMethod; // 'credit_card', 'paypal', 'bank_transfer'
  final String? projectTitle; // For project donations
  final String? projectDescription; // For project donations

  const Donation({
    required this.id,
    required this.amount,
    required this.currency,
    required this.donationType,
    required this.category,
    required this.donorId,
    required this.donorName,
    required this.createdAt,
    required this.status,
    this.paymentMethod,
    this.projectTitle,
    this.projectDescription,
  });

  Donation copyWith({
    String? id,
    double? amount,
    String? currency,
    String? donationType,
    String? category,
    String? donorId,
    String? donorName,
    DateTime? createdAt,
    String? status,
    String? paymentMethod,
    String? projectTitle,
    String? projectDescription,
  }) {
    return Donation(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      donationType: donationType ?? this.donationType,
      category: category ?? this.category,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      projectTitle: projectTitle ?? this.projectTitle,
      projectDescription: projectDescription ?? this.projectDescription,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'donationType': donationType,
      'category': category,
      'donorId': donorId,
      'donorName': donorName,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'projectTitle': projectTitle,
      'projectDescription': projectDescription,
    };
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      donationType: json['donationType'] as String,
      category: json['category'] as String,
      donorId: json['donorId'] as String,
      donorName: json['donorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      projectTitle: json['projectTitle'] as String?,
      projectDescription: json['projectDescription'] as String?,
    );
  }
} 