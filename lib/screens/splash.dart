import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(children: [
            Positioned(top: -80, right: -50, child: _GlowCircle(size: 220)),
            Positioned(bottom: -80, left: -70, child: _GlowCircle(size: 240)),
            SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(23), border: Border.all(color: Colors.white.withOpacity(.23))), child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 36)),
              const SizedBox(height: 20),
              Text('Ekfalni', style: GoogleFonts.cairo(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w800)),
              Text('نصنع أثرًا يستمر', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 36),
              Image.asset('images/splash_image.png', height: 235, fit: BoxFit.contain),
              const SizedBox(height: 28),
              Text('كل طفل يستحق فرصة لغدٍ أجمل', textAlign: TextAlign.center, style: GoogleFonts.cairo(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('تبرع، اكفل، وكن جزءًا من حكاية أثر حقيقية', textAlign: TextAlign.center, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 35),
              const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondaryColor)),
            ]))))
          ]),
        ),
      );
}

class _GlowCircle extends StatelessWidget { final double size; const _GlowCircle({required this.size}); @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.06))); }
