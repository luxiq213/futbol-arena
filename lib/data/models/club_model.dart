import 'package:flutter/material.dart';

enum BadgePattern {
  stripesVertical, // Fenerbahçe, Beşiktaş, Barcelona, Juventus, Milan, Inter, Atletico
  halves,          // Galatasaray, Monaco
  diagonalSash,    // Trabzonspor, Porto
  solidWithTrim,   // Real Madrid, Chelsea, Liverpool, Bayern, Dortmund, PSG, Arsenal, Man City
}

class ClubModel {
  final String id;
  final String name;
  final String shortName;
  final String country;
  final String league;
  final Color primaryColor;
  final Color secondaryColor;
  final Color? accentColor;
  final BadgePattern pattern;

  const ClubModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.country,
    required this.league,
    required this.primaryColor,
    required this.secondaryColor,
    this.accentColor,
    this.pattern = BadgePattern.solidWithTrim,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shortName': shortName,
    'country': country,
    'league': league,
    'pattern': pattern.name,
  };
}
