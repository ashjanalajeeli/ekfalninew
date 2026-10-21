import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/donation/screens/donation.dart';
import '../features/sponsor/screens/sponsor.dart';
import '../l10n.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  bool _showTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 220;
      if (shouldShow != _showTopButton) setState(() => _showTopButton = shouldShow);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final isArabic = ref.watch(languageProvider).languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        drawer: const _HomeDrawer(),
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: Row(
            children: [
              Builder(builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                    color: AppTheme.textColor,
                  )),
              const SizedBox(width: 2),
              const _BrandMark(),
              const SizedBox(width: 9),
              Text('Ekfalni', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: AppTheme.textColor, fontSize: 18)),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد إشعارات جديدة'))),
              icon: const Icon(Icons.notifications_none_rounded),
              color: AppTheme.textColor,
            ),
            const Padding(padding: EdgeInsetsDirectional.only(end: 18), child: _ProfileDot()),
          ],
        ),
        floatingActionButton: _showTopButton
            ? FloatingActionButton.small(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                onPressed: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 450), curve: Curves.easeOut),
                child: const Icon(Icons.keyboard_arrow_up_rounded),
              ).animate().scale()
            : null,
        body: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 500)),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
            children: [
              Text('مرحبًا أشجان،', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 13)).animate().fadeIn(),
              const SizedBox(height: 2),
              Text('لنصنع أثرًا اليوم', style: AppTheme.headingStyle).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),
              _buildHero(context, tr).animate().fadeIn(delay: 150.ms).slideY(begin: .08, end: 0),
              const SizedBox(height: 25),
              _SectionHeader(title: 'الأثر هذا الشهر', action: 'التفاصيل'),
              const SizedBox(height: 12),
              _buildImpactCard(),
              const SizedBox(height: 27),
              _SectionHeader(title: 'حملات تحتاج دعمك', action: 'عرض الكل'),
              const SizedBox(height: 12),
              SizedBox(
                height: 229,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: isArabic,
                  children: [
                    _CampaignCard(title: 'تعليم يصنع غدًا', subtitle: 'مستلزمات وفرص تعليمية', current: '18,420', target: '25,000', image: 'images/child_donation.png', color: AppTheme.primaryColor),
                    _CampaignCard(title: 'بيوت أكثر أمانًا', subtitle: 'احتياجات الأسر الأساسية', current: '12,860', target: '20,000', image: 'images/mysponsor.jpg', color: const Color(0xFFD5912A)),
                    _CampaignCard(title: 'دفء الشتاء', subtitle: 'كسوة واحتياجات الشتاء', current: '9,750', target: '15,000', image: 'images/cloths.png', color: const Color(0xFF3C9E9B)),
                  ],
                ),
              ),
              const SizedBox(height: 27),
              _SectionHeader(title: 'ابدأ بخطوة بسيطة', action: ''),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _QuickAction(icon: Icons.volunteer_activism_rounded, title: 'تبرع الآن', subtitle: 'ساهم في حملة', color: AppTheme.softPurple, iconColor: AppTheme.primaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => donation())))),
                const SizedBox(width: 12),
                Expanded(child: _QuickAction(icon: Icons.favorite_rounded, title: 'اكفل طفلًا', subtitle: 'رعاية مستمرة', color: AppTheme.softGold, iconColor: const Color(0xFFC18320), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => sponsor())))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppLocalizations tr) {
    return Container(
      height: 192,
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(27), boxShadow: const [BoxShadow(color: Color(0x307657E8), blurRadius: 20, offset: Offset(0, 10))]),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        PositionedDirectional(end: -18, top: -18, child: Container(width: 145, height: 145, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.08)))),
        PositionedDirectional(end: 12, bottom: -55, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.secondaryColor.withOpacity(.13)))),
        Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('أثر صغير، فرق كبير', style: GoogleFonts.cairo(color: AppTheme.secondaryColor, fontWeight: FontWeight.w700, fontSize: 11)),
          const SizedBox(height: 7),
          Text('كل مساهمة تفتح\nبابًا جديدًا', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, height: 1.35)),
          const SizedBox(height: 13),
          ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => donation())), icon: const Icon(Icons.arrow_back_rounded, size: 16), label: Text(tr.translate('تبرع الان')), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor, foregroundColor: const Color(0xFF3A260A), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800))),
        ])),
        PositionedDirectional(start: 7, bottom: -4, child: Image.asset('images/splash_image.png', width: 150, height: 150, fit: BoxFit.contain)),
      ]),
    );
  }

  Widget _buildImpactCard() => Container(decoration: AppTheme.cardDecoration, padding: const EdgeInsets.all(17), child: Row(children: [
    Container(width: 52, height: 52, decoration: BoxDecoration(color: AppTheme.softGold, borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFC18320))),
    const SizedBox(width: 13),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('إجمالي مساهماتك', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 11)), const SizedBox(height: 3), Text('4,850 ر.س', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('ساهمت في رعاية 8 حالات هذا العام', style: GoogleFonts.cairo(color: AppTheme.successColor, fontSize: 9))])),
    Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.softPurple, border: Border.all(color: AppTheme.primaryColor.withOpacity(.3), width: 5)), child: Center(child: Text('72%', style: GoogleFonts.cairo(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w800))),),
  ]));
}

class _BrandMark extends StatelessWidget { const _BrandMark(); @override Widget build(BuildContext context) => Container(width: 35, height: 35, decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 19)); }
class _ProfileDot extends StatelessWidget { const _ProfileDot(); @override Widget build(BuildContext context) => Container(width: 34, height: 34, decoration: BoxDecoration(color: AppTheme.secondaryColor, borderRadius: BorderRadius.circular(12)), child: Center(child: Text('أ', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: const Color(0xFF39250C))))); }
class _SectionHeader extends StatelessWidget { final String title; final String action; const _SectionHeader({required this.title, required this.action}); @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: AppTheme.subheadingStyle.copyWith(fontSize: 16)), if (action.isNotEmpty) TextButton(onPressed: () {}, child: Text(action, style: GoogleFonts.cairo(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w700)))]); }
class _CampaignCard extends StatelessWidget { final String title, subtitle, current, target, image; final Color color; const _CampaignCard({required this.title, required this.subtitle, required this.current, required this.target, required this.image, required this.color}); @override Widget build(BuildContext context) { final progress = double.parse(current.replaceAll(',', '')) / double.parse(target.replaceAll(',', '')); return Container(width: 245, margin: const EdgeInsetsDirectional.only(end: 12), decoration: AppTheme.cardDecoration, clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 104, width: double.infinity, child: Stack(fit: StackFit.expand, children: [Image.asset(image, fit: BoxFit.cover), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(.05), Colors.black.withOpacity(.6)], begin: Alignment.topCenter, end: Alignment.bottomCenter))), PositionedDirectional(top: 10, end: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)), child: Text('نشطة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))))])), Padding(padding: const EdgeInsets.fromLTRB(13, 10, 13, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: const Color(0xFFEDEBF6), valueColor: AlwaysStoppedAnimation<Color>(color))), const SizedBox(height: 7), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$current ر.س', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 9, fontWeight: FontWeight.w800)), Text('من $target', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8))])]))])); } }
class _QuickAction extends StatelessWidget { final IconData icon; final String title, subtitle; final Color color, iconColor; final VoidCallback onTap; const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.color, required this.iconColor, required this.onTap}); @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(13), decoration: AppTheme.cardDecoration, child: Row(children: [Container(width: 39, height: 39, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: iconColor, size: 19)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.cairo(color: AppTheme.textColor, fontWeight: FontWeight.w800, fontSize: 11)), Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))]))]))); }
class _HomeDrawer extends StatelessWidget { const _HomeDrawer(); @override Widget build(BuildContext context) => Drawer(backgroundColor: AppTheme.backgroundColor, child: SafeArea(child: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(24, 25, 24, 22), decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _BrandMark(), const SizedBox(height: 19), Text('مرحبًا بك في Ekfalni', style: GoogleFonts.cairo(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)), Text('معًا نصنع أثرًا يستمر', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11))])), const SizedBox(height: 15), _DrawerItem(icon: Icons.person_outline_rounded, label: 'الملف الشخصي', onTap: () => Navigator.pushNamed(context, '/profile')), _DrawerItem(icon: Icons.settings_outlined, label: 'الإعدادات', onTap: () => Navigator.pushNamed(context, '/settingpage')), _DrawerItem(icon: Icons.help_outline_rounded, label: 'المساعدة', onTap: () => Navigator.pushNamed(context, '/helppage')), const Spacer(), const Divider(indent: 20, endIndent: 20), _DrawerItem(icon: Icons.logout_rounded, label: 'تسجيل الخروج', color: Colors.redAccent, onTap: () => Navigator.pushReplacementNamed(context, '/login')), const SizedBox(height: 20)]))); }
class _DrawerItem extends StatelessWidget { final IconData icon; final String label; final VoidCallback onTap; final Color? color; const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color}); @override Widget build(BuildContext context) => ListTile(onTap: onTap, leading: Icon(icon, color: color ?? AppTheme.primaryColor), title: Text(label, style: GoogleFonts.cairo(color: color ?? AppTheme.textColor, fontWeight: FontWeight.w600, fontSize: 13)), trailing: Icon(Icons.chevron_left_rounded, color: (color ?? AppTheme.subtitleColor))); }
