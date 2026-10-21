import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7657E8);
  static const Color primaryDark = Color(0xFF4C35B5);
  static const Color secondaryColor = Color(0xFFF3B94F);
  static const Color accentColor = Color(0xFF9C83FF);
  static const Color backgroundColor = Color(0xFFF7F7FC);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF18213A);
  static const Color subtitleColor = Color(0xFF77809A);
  static const Color successColor = Color(0xFF38B982);
  static const Color softPurple = Color(0xFFF0EDFF);
  static const Color softGold = Color(0xFFFFF5DE);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static TextStyle get headingStyle => GoogleFonts.cairo(
        fontSize: 25,
        fontWeight: FontWeight.w800,
        color: textColor,
        height: 1.35,
      );

  static TextStyle get subheadingStyle => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
      );

  static TextStyle get bodyStyle => GoogleFonts.cairo(
        fontSize: 14,
        color: textColor,
        height: 1.7,
      );

  static TextStyle get buttonTextStyle => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9E8F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B2140),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      );

  static InputDecoration inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: subtitleColor, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF7F7FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      );

  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: buttonTextStyle,
      );

  static PageTransitionsTheme get pageTransitionsTheme => PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CustomPageTransitionBuilder(),
          TargetPlatform.iOS: CustomPageTransitionBuilder(),
        },
      );
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(0.08, 0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));
    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
