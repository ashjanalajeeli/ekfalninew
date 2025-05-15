import 'package:flutter/material.dart';

class mysponsor extends StatelessWidget {
  const mysponsor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.teal,
        title: const Text('سجل الكفالات', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'قائمة الكفالات المنفذة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ..._buildKafalaHistory(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKafalaHistory() {
    final List<Map<String, String>> kafalat = [
      {
        'title': 'كفالة يتيم - عبدالله',
        'date': '1 مارس، 2024',
        'amount': '500 ريال',
        'duration': 'يناير 2024 - مارس 2024'
      },
      {
        'title': 'كفالة يتيم - هدى',
        'date': '1 فبراير، 2024',
        'amount': '500 ريال',
        'duration': 'ديسمبر 2023 - فبراير 2024'
      },
      {
        'title': 'كفالة يتيم - محمد',
        'date': '1 يناير، 2024',
        'amount': '500 ريال',
        'duration': 'نوفمبر 2023 - يناير 2024'
      },
      {
        'title': 'كفالة يتيم - عائشة',
        'date': '1 ديسمبر، 2023',
        'amount': '500 ريال',
        'duration': 'أكتوبر 2023 - ديسمبر 2023'
      },
      {
        'title': 'كفالة يتيم - خالد',
        'date': '1 نوفمبر، 2023',
        'amount': '500 ريال',
        'duration': 'سبتمبر 2023 - نوفمبر 2023'
      },
    ];

    return kafalat.map((kafala) {
      return KafalaItem(
        title: kafala['title']!,
        date: kafala['date']!,
        amount: kafala['amount']!,
        duration: kafala['duration']!,
      );
    }).toList();
  }
}

class KafalaItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String duration;

  const KafalaItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Directionality( // ✅ جعل المحتوى من اليمين لليسار
        textDirection: TextDirection.rtl,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            date,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          trailing: Text(
            amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
      ),
    );
  }
}
