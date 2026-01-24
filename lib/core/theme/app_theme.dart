import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  AppDesignTokens get tokens => theme.extension<AppDesignTokens>() ?? AppTheme.defaultTokens;
}

class AppDesignTokens extends ThemeExtension<AppDesignTokens> {
  final LinearGradient balanceGradient;
  final BoxShadow cardShadow;

  AppDesignTokens({
    required this.balanceGradient,
    required this.cardShadow,
  });

  @override
  ThemeExtension<AppDesignTokens> copyWith({
    LinearGradient? balanceGradient,
    BoxShadow? cardShadow,
  }) {
    return AppDesignTokens(
      balanceGradient: balanceGradient ?? this.balanceGradient,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  ThemeExtension<AppDesignTokens> lerp(
    ThemeExtension<AppDesignTokens>? other,
    double t,
  ) {
    if (other is! AppDesignTokens) return this;
    return AppDesignTokens(
      balanceGradient: LinearGradient.lerp(balanceGradient, other.balanceGradient, t)!,
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

class AppTheme {
  // Brand Colors
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color softBackground = Color(0xFFF9FAFB);
  static const Color darkBackground = Color(0xFF111827);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

  static final _lightTokens = AppDesignTokens(
    balanceGradient: const LinearGradient(
      colors: [primaryPurple, accentPink],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  );

  static final _darkTokens = AppDesignTokens(
    balanceGradient: const LinearGradient(
      colors: [primaryPurple, accentPink],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  );

  static final defaultTokens = _lightTokens;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: softBackground,
    colorScheme: ColorScheme.light(
      primary: primaryPurple,
      secondary: accentPink,
      surface: Colors.white,
      onSurface: textDark,
      surfaceContainerHighest: Color(0xFFF3F4F6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: textLight),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textDark),
      bodyMedium: TextStyle(color: textLight),
    ),
    extensions: [_lightTokens],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: accentPink,
      surface: Color(0xFF1F2937),
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF374151),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: const Color(0xFF1F2937),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F2937),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFF9CA3AF)),
    ),
    extensions: [_darkTokens],
  );
}
