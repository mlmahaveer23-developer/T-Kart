import 'package:flutter/material.dart';

/// Maps the backend-agnostic `iconKey` stored on [Category] to an actual
/// Flutter icon. Add a case here whenever a new category icon key is
/// introduced in the `categories` table.
IconData categoryIcon(String iconKey) {
  switch (iconKey) {
    case 'staples':
      return Icons.rice_bowl_rounded;
    case 'snacks':
      return Icons.cookie_rounded;
    case 'personal_care':
      return Icons.spa_rounded;
    case 'household':
      return Icons.cleaning_services_rounded;
    default:
      return Icons.category_rounded;
  }
}
