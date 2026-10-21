import 'package:flutter/material.dart';
import '../screens/homepage.dart';
import 'package:ekfalninew/features/donation/screens/donation.dart';
import 'package:ekfalninew/features/sponsor/screens/sponsor.dart';
import 'package:ekfalninew/features/association/screens/Association.dart';
import '../theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [HomePage(), const donation(), const sponsor(), Association()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(.97), borderRadius: BorderRadius.circular(23), boxShadow: const [BoxShadow(color: Color(0x1A1B2140), blurRadius: 22, offset: Offset(0, 8))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: NavigationBar(
              height: 68,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.softPurple,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
                NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'التبرعات'),
                NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism_rounded), label: 'الكفالة'),
                NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment_rounded), label: 'الجمعيات'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
