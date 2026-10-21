import 'package:ekfalninew/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/main_navigation.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  bool _isValidPassword(String password) => RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$').hasMatch(password);

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: GoogleFonts.cairo()), backgroundColor: const Color(0xFFB53D54), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_isValidEmail(email)) {
      _showError('أدخلي بريدًا إلكترونيًا صحيحًا');
      return;
    }
    if (!_isValidPassword(password)) {
      _showError('كلمة المرور يجب أن تحتوي على 8 أحرف ورقم ورمز وحرف كبير');
      return;
    }
    try {
      await ref.read(authProvider.notifier).signIn(email, password);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
    } catch (_) {
      _showError('لم نتمكن من تسجيل الدخول. يمكنك إنشاء حساب جديد.');
      if (mounted) Navigator.pushNamed(context, '/signup');
    }
  }

  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) => next.whenOrNull(error: (error, stackTrace) => _showError(error.toString())));
    final authState = ref.watch(authProvider);
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: AppTheme.backgroundColor, body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 20, 22, 30), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [const _LoginBrand(), const Spacer(), TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: Text('حساب جديد', style: GoogleFonts.cairo(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w700)))]),
      const SizedBox(height: 25),
      Container(height: 235, decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(28)), clipBehavior: Clip.antiAlias, child: Stack(children: [Positioned(top: -45, left: -35, child: _SoftCircle(size: 155)), Positioned(bottom: -28, right: -25, child: _SoftCircle(size: 145)), Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('معًا نصنع أثرًا', style: GoogleFonts.cairo(color: AppTheme.secondaryColor, fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 7), Text('كل طفل يستحق\nغدًا أجمل', style: GoogleFonts.cairo(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.35)), const SizedBox(height: 9), Text('تبرع، اكفل، وكن جزءًا من رحلة خير حقيقية', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10))])), Positioned(left: -10, bottom: -4, child: Image.asset('images/splash_image.png', width: 150, height: 150, fit: BoxFit.contain))])),
      const SizedBox(height: 30),
      Text('مرحبًا بعودتك', style: AppTheme.headingStyle),
      const SizedBox(height: 5),
      Text('سجّلي الدخول لمتابعة أثرك وكفالاتك', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 12)),
      const SizedBox(height: 22),
      TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: AppTheme.inputDecoration('البريد الإلكتروني').copyWith(prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppTheme.primaryColor))),
      const SizedBox(height: 13),
      TextField(controller: _passwordController, obscureText: _obscurePassword, decoration: AppTheme.inputDecoration('كلمة المرور').copyWith(prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryColor), suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.subtitleColor)))),
      Align(alignment: AlignmentDirectional.centerStart, child: TextButton(onPressed: () => _showError('سيتم إرسال رابط استعادة كلمة المرور'), child: Text('نسيت كلمة المرور؟', style: GoogleFonts.cairo(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w700)))),
      const SizedBox(height: 5),
      SizedBox(height: 52, child: ElevatedButton(onPressed: authState.isLoading ? null : _handleLogin, style: AppTheme.elevatedButtonStyle, child: authState.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('تسجيل الدخول', style: AppTheme.buttonTextStyle))),
      const SizedBox(height: 18),
      Row(children: [const Expanded(child: Divider(color: Color(0xFFE2E1EB))), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('أو', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 10))), const Expanded(child: Divider(color: Color(0xFFE2E1EB)))]),
      const SizedBox(height: 18),
      OutlinedButton.icon(onPressed: () => _showError('تسجيل الدخول عبر Google متاح بعد ربط الخدمة'), icon: const Icon(Icons.g_mobiledata_rounded, color: AppTheme.textColor, size: 23), label: Text('المتابعة باستخدام Google', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, fontWeight: FontWeight.w700)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE3E2EC)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      const SizedBox(height: 20),
      Center(child: Wrap(alignment: WrapAlignment.center, children: [Text('ليس لديك حساب؟ ', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 11)), GestureDetector(onTap: () => Navigator.pushNamed(context, '/signup'), child: Text('أنشئي حسابًا الآن', style: GoogleFonts.cairo(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w800)))])),
    ]))));
  }
}

class _LoginBrand extends StatelessWidget { const _LoginBrand(); @override Widget build(BuildContext context) => Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 18)), const SizedBox(width: 9), Text('Ekfalni', style: GoogleFonts.cairo(color: AppTheme.textColor, fontWeight: FontWeight.w800, fontSize: 18))]); }
class _SoftCircle extends StatelessWidget { final double size; const _SoftCircle({required this.size}); @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.08))); }
