import 'package:flutter/material.dart';
import 'AssociationProjects.dart';
import 'AssociationModel.dart';
import 'package:ekfalninew/drawer/CustomDrawer.dart';
import 'package:ekfalninew/theme/app_theme.dart';

class Association extends StatelessWidget {
  final List<AssociationModel> associations = [
    AssociationModel(
      name: 'جمعية البر الخيرية',
      logoUrl: 'assets/images/logo1.png',
      description: 'توفر الجمعية الدعم للأسر المحتاجة، وتشمل خدماتها الأيتام.',
      location: 'حضرموت، اليمن',
      email: 'info@albir.org.sa',
      orphanCount: 120,
      projectCount: 8,
    ),
    AssociationModel(
      name: 'جمعية كافل اليتيم',
      logoUrl: 'assets/images/logo2.png',
      description: 'تهدف إلى كفالة الأيتام وتوفير الرعاية الصحية والتعليم.',
      location: 'حضرموت، اليمن',
      email: 'contact@kafel.org.sa',
      orphanCount: 200,
      projectCount: 11,
    ),
    AssociationModel(
      name: 'جمعية الأمل',
      logoUrl: 'assets/images/logo3.png',
      description: 'تدعم الفئات الضعيفة عبر مشاريع اجتماعية وتنموية.',
      location: 'حضرموت، اليمن',
      email: 'support@alamal.org.sa',
      orphanCount: 75,
      projectCount: 6,
    ),
    // أضف هنا 4 جمعيات إضافية بنفس التنسيق...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('الجمعيات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
      ),

      endDrawer: const drawer(),
      body: ListView.builder(
        itemCount: associations.length,
        itemBuilder: (context, index) {
          final a = associations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssociationProjects(associationName: a.name),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(a.logoUrl),
                          radius: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                a.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Text(
                                a.description,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconInfo(icon: Icons.place, text: a.location??'غير معروف'),
                        IconInfo(icon: Icons.email, text: a.email),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconInfo(icon: Icons.people, text: 'عدد الأيتام: ${a.orphanCount}'),
                        IconInfo(icon: Icons.folder_copy, text: 'عدد المشاريع: ${a.projectCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class IconInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconInfo({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
