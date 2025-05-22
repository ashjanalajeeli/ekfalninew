import 'package:flutter/material.dart';

class AssociationProjects extends StatelessWidget {
  final String associationName;

  const AssociationProjects({super.key, required this.associationName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> projects = [
      {
        'title': 'مشروع كفالة الأيتام',
        'description': 'توفير كفالة مالية للأيتام تغطي التعليم والمعيشة.'
      },
      {
        'title': 'مشروع الحقيبة المدرسية',
        'description': 'توفير مستلزمات مدرسية للأطفال المحتاجين.'
      },
      {
        'title': 'مشروع توزيع الطعام',
        'description': 'توزيع سلال غذائية على الأسر المحتاجة.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('مشاريع - $associationName'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView.builder(
          itemCount: projects.length,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemBuilder: (context, index) {
            final project = projects[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                title: Text(
                  project['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.right,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    project['description']!,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.right,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.teal),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/project_details',
                    arguments: {
                      'projectTitle': project['title'],
                      'projectDescription': project['description'],
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
