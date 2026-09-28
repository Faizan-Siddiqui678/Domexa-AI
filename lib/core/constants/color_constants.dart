import 'package:flutter/material.dart';

class AppColors {
  // Primary brand
  static const Color primary       = Color(0xFF1565C0);
  static const Color primaryDark   = Color(0xFF0D47A1);
  static const Color primaryLight  = Color(0xFF1976D2);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // Gold accent
  static const Color gold          = Color(0xFFF59E0B);
  static const Color goldLight     = Color(0xFFFFF8E1);

  // Backgrounds
  static const Color background    = Color(0xFFF8FAFC);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color bgInput       = Color(0xFFF1F5F9);
  static const Color border        = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary   = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted     = Color(0xFF94A3B8);

  // Status
  static const Color success       = Color(0xFF059669);
  static const Color successLight  = Color(0xFFECFDF5);
  static const Color error         = Color(0xFFDC2626);
  static const Color errorLight    = Color(0xFFFEF2F2);
  static const Color warning       = Color(0xFFD97706);
  static const Color warningLight  = Color(0xFFFFFBEB);
  static const Color info          = Color(0xFF0284C7);
  static const Color infoLight     = Color(0xFFE0F2FE);

  // Feature card colors
  static const Color cardLayout    = Color(0xFF6366F1);
  static const Color cardMaterials = Color(0xFF059669);
  static const Color cardCost      = Color(0xFFEA580C);
  static const Color cardInterior  = Color(0xFF7C3AED);

  // Budget colors
  static const Color budgetLow     = Color(0xFF059669);
  static const Color budgetMedium  = Color(0xFF1565C0);
  static const Color budgetHigh    = Color(0xFF7C3AED);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}