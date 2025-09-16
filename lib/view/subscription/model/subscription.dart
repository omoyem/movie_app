import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String duration;
  final String price;
  final String monthlyPrice;
  final String totalPrice;
  final bool isBestOffer;

  SubscriptionPlan({
    required this.duration,
    required this.price,
    required this.monthlyPrice,
    required this.totalPrice,
    this.isBestOffer = false,
  });
}

class Feature {
  final IconData icon;
  final String title;
  final String description;

  Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
