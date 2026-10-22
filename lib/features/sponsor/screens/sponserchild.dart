import 'package:flutter/material.dart';
import 'orphan_details.dart';

class sponsorchild extends StatelessWidget {
  const sponsorchild({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFAA5156),
          title: const Text('كفالة يتيم'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepItem(
                title: 'الخطوة ١: اختر يتيماً',
                description: 'مساهمتك: ٥٠\$ شهرياً\nستساعد كفالتك في توفير الغذاء والرعاية الصحية والتعليم.',
              ),
              const StepItem(
                title: 'الخطوة ٢: إعداد المدفوعات',
                description: 'مساهمتك: ٥٠\$ شهرياً\nيمكنك تغيير أو إلغاء الكفالة في أي وقت.',
              ),
              const SizedBox(height: 30),
              const Text(
                'الأيتام المتاحين للكفالة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFAA5156)),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: ChildCard(
                      name: 'لورينا، ٤ سنوات',
                      location: 'المكسيك',
                      imagePath: 'assets/images/child1.jpg',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ChildCard(
                      name: 'ماريا، ٣ سنوات',
                      location: 'هندوراس',
                      imagePath: 'assets/images/child1.jpg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'لدينا أيتام في ٧ دول ينتظرون الدعم...',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAA5156),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ابدأ الكفالة',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepItem extends StatelessWidget {
  final String title;
  final String description;

  const StepItem({
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFAA5156)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAA5156),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChildCard extends StatelessWidget {
  final String name;
  final String location;
  final String imagePath;

  const ChildCard({
    required this.name,
    required this.location,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrphanDetailsScreen())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
