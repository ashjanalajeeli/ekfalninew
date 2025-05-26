// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SponsorModel _$SponsorModelFromJson(Map<String, dynamic> json) => SponsorModel(
      id: json['id'] as String,
      orphanId: json['orphanId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: json['frequency'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SponsorModelToJson(SponsorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orphanId': instance.orphanId,
      'userId': instance.userId,
      'amount': instance.amount,
      'frequency': instance.frequency,
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
