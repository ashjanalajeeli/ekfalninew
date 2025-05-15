import 'package:flutter/material.dart';
import '../screens/homepage.dart';
import 'package:ekfalninew/features/donation/screens/donation.dart';
import 'package:ekfalninew/features/sponsor/screens/sponsor.dart';
import 'package:ekfalninew/features/association/screens/Association.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    donation(),
    sponsor(),
    Association(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "الرئيسية",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: "التبرعات",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism_outlined),
                label: "الكفالة",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.apartment),
                label: "الجمعيات",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
