import 'package:json_annotation/json_annotation.dart';

part 'sponsor_model.g.dart';

@JsonSerializable()
class SponsorModel {
  final String id;
  final String orphanId;
  final String userId;
  final double amount;
  final String frequency;
  final String status;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  SponsorModel({
    required this.id,
    required this.orphanId,
    required this.userId,
    required this.amount,
    required this.frequency,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SponsorModel.fromJson(Map<String, dynamic> json) =>
      _$SponsorModelFromJson(json);

  Map<String, dynamic> toJson() => _$SponsorModelToJson(this);

  SponsorModel copyWith({
    String? id,
    String? orphanId,
    String? userId,
    double? amount,
    String? frequency,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SponsorModel(
      id: id ?? this.id,
      orphanId: orphanId ?? this.orphanId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 