import 'package:flutter/material.dart';
import 'AssociationProjects.dart';
import 'AssociationModel.dart';

class AssociationModel {
  final String name;
  final String logoUrl;
  final String description;
  final String? location;
  final String email;
  final int orphanCount;
  final int projectCount;

  AssociationModel({
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.location,
    required this.email,
    required this.orphanCount,
    required this.projectCount,
  });
}
