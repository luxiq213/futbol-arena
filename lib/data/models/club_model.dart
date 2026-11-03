import 'package:flutter/material.dart';

class ClubModel {
  final String id;
  final String name;
  final String shortName;
  final String country;
  final String league;
  final Color primaryColor;
  final Color secondaryColor;
  final String badgeText;

  const ClubModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.country,
    required this.league,
    required this.primaryColor,
    required this.secondaryColor,
    required this.badgeText,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shortName': shortName,
    'country': country,
    'league': league,
    'badgeText': badgeText,
  };
}
