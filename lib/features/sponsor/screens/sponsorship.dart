import 'package:flutter/material.dart';
import 'sponsorshipconfirmation.dart';

class sponsorship extends StatelessWidget {
  final List<Map<String, dynamic>> sponsorships = [
    {
      'name': 'إيما',
      'duration': 12,
      'amount': 300,
      'image': 'https://i.imgur.com/BoN9kdC.png',
      'isSponsored': true,
    },
    {
      'name': 'آيدن',
      'duration': 6,
      'amount': 150,
      'image': 'https://i.imgur.com/BoN9kdC.png',
      'isSponsored': false,
    },
    {
      'name': 'أوليفيا',
      'duration': 24,
      'amount': 600,
      'image': 'https://i.imgur.com/BoN9kdC.png',
      'isSponsored': false,
    },
  ];

  final List<String> notifications = [
    "ستنتهي كفالة إيما خلال شهر واحد. يرجى التجديد.",
    "ستنتهي كفالة آيدن خلال شهرين. يرجى التجديد.",
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text('الكفالات', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "الكفالات الحالية",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sponsorships.length,
                  itemBuilder: (context, index) {
                    final sponsor = sponsorships[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(sponsor['image']),
                              radius: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sponsor['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('المدة: ${sponsor['duration']} شهور'),
                                  Text('المبلغ الشهري: \$${sponsor['amount']}'),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: sponsor['isSponsored']
                                  ? null
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SponsorshipConfirmation(
                                      orphanName: sponsor['name'],
                                      duration: sponsor['duration'],
                                      amount: sponsor['amount'],
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sponsor['isSponsored']
                                    ? Colors.grey[850]
                                    : Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                sponsor['isSponsored'] ? 'مكفول بالفعل' : 'كفالة',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "الإشعارات",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: notifications.map((note) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // تقدر هنا تحدد ماذا يحدث عند الضغط على زر تجديد
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم الضغط على زر التجديد')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text(
                            'تجديد',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
