import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF009688); // Teal
  static const Color secondaryColor = Color(0xFF80CBC4); // Light Teal
  static const Color accentColor = Color(0xFF26A69A); // Teal variant
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2D2D2D);
  static const Color subtitleColor = Color(0xFF757575);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle get subheadingStyle => GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static TextStyle get bodyStyle => GoogleFonts.cairo(
    fontSize: 16,
    color: textColor,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Input Decoration
  static InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.cairo(
      color: subtitleColor,
      fontSize: 16,
    ),
    filled: true,
    fillColor: backgroundColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
  );

  // Button Style
  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );

  // Page Transitions
  static PageTransitionsTheme get pageTransitionsTheme => PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CustomPageTransitionBuilder(),
      TargetPlatform.iOS: CustomPageTransitionBuilder(),
    },
  );
}

// Custom Page Transition Animation
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
} 