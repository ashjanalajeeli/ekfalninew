import 'package:flutter/material.dart';
import 'OrphanSponsorship.dart'; // صفحة شروط الكفالة
import 'mysponsor.dart'; // صفحة كفالاتي
import 'sponsorship.dart'; // صفحة الكفالة الرئيسية
import 'sponserchild.dart';
import 'package:ekfalninew/drawer/CustomDrawer.dart';

class sponsor extends StatelessWidget {
  const sponsor({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor:  Colors.teal,
          title: const Text('كفالة',style: TextStyle(color: Colors.white),),
          centerTitle: true,
          elevation: 0,
        ),


        endDrawer: const drawer(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildCard(context, Icons.handshake_rounded, 'كفالة'),
              _buildCard(context, Icons.book_online_rounded, 'شروط الكفالة'),
              _buildCard(context, Icons.history_rounded, 'كفالاتي'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'كفالة') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => sponsorship()));
        } else if (label == 'شروط الكفالة') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => OrphanSponsorshipPage()));
        } else if (label == 'كفالاتي') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => mysponsor()));
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        color: Colors.pink.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(icon, size: 40, color: Colors.teal),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
