import 'package:flutter/material.dart';

class Plan {
  final String name;
  final List<String> features;
  final String monthlyPrice;
  final String yearlyPrice;
  final Color gradientStartColor;
  final Color gradientEndColor;

  Plan({
    @required this.name,
    @required this.features,
    @required this.monthlyPrice,
    @required this.yearlyPrice,
    @required this.gradientStartColor,
    @required this.gradientEndColor,
  });
}
