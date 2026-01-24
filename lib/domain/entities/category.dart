import 'package:flutter/material.dart';

class Category {
  final String id;          // Unique ID
  final String name;        // Category name, e.g., "Food", "Rent"
  final Color color;        // Color to show in UI
  final IconData icon;      // Icon for category
  final String? monthlyBudgetId; // Reference to the monthly budget it belongs to

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.monthlyBudgetId,
  });
}
