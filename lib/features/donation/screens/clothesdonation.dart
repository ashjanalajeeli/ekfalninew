import 'package:flutter/material.dart';

class DonationClothesScreen extends StatefulWidget {
  @override
  _DonationClothesScreenState createState() => _DonationClothesScreenState();
}

class _DonationClothesScreenState extends State<DonationClothesScreen> {
  final List<String> clothes = ['قمصان', 'بنطلونات', 'أحذية', 'جاكيتات', 'شالات'];
  final Map<String, TextEditingController> controllers = {};
  String? selectedBeneficiary;
  String? selectedDelivery;
  List<String> projects = ['مشروع رعاية الأيتام', 'مشروع كسوة الشتاء', 'مشروع سقيا الماء'];
  String? selectedProject;
  List<String> selectedOrphans = [];

  @override
  void initState() {
    super.initState();
    for (var item in clothes) {
      controllers[item] = TextEditingController(text: '0');
    }
  }

  Widget buildClothingItem(String item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(item, style: const TextStyle(fontSize: 16)),
          ),
          Container(
            width: 80,
            child: TextField(
              controller: controllers[item],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildOption({
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          ],
        ),
      ),
    );
  }

  void addOrphan(String orphanName) {
    setState(() {
      selectedOrphans.add(orphanName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تبرع بالملابس',style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text("أصناف الملابس", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ...clothes.map((item) => buildClothingItem(item)).toList(),
              const SizedBox(height: 20),
              const Text("اختيار المستفيد", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              buildOption(
                value: 'يتيم',
                groupValue: selectedBeneficiary ?? '',
                onChanged: (val) => setState(() {
                  selectedBeneficiary = val;
                  selectedProject = null;
                  selectedOrphans.clear();
                }),
                label: 'يتيم',
                color: Colors.grey.shade300,
              ),
              if (selectedBeneficiary == 'يتيم') ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (context) => OrphansListScreen()),
                    );
                    if (result != null) {
                      addOrphan(result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('اختيار يتيم', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                if (selectedOrphans.isNotEmpty) ...[
                  const Text("الأيتام المختارين:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...selectedOrphans.map((orphan) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(orphan, style: const TextStyle(fontSize: 15)),
                  ))
                ],
              ],
              buildOption(
                value: 'مشروع',
                groupValue: selectedBeneficiary ?? '',
                onChanged: (val) => setState(() {
                  selectedBeneficiary = val;
                  selectedOrphans.clear();
                  selectedProject = null;
                }),
                label: 'مشروع',
                color: Colors.grey.shade300,
              ),
              if (selectedBeneficiary == 'مشروع') ...[
                const SizedBox(height: 10),
                const Text("اختر المشروع", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedProject,
                  items: projects.map((proj) {
                    return DropdownMenuItem(
                      value: proj,
                      child: Text(proj),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() {
                    selectedProject = val;
                  }),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text("طريقة التوصيل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              buildOption(
                value: 'توصيل شخصي',
                groupValue: selectedDelivery ?? '',
                onChanged: (val) => setState(() => selectedDelivery = val),
                label: 'توصيل شخصي',
                color: Colors.teal.shade100,
              ),
              buildOption(
                value: 'عن طريق الجمعية',
                groupValue: selectedDelivery ?? '',
                onChanged: (val) => setState(() => selectedDelivery = val),
                label: 'عن طريق الجمعية',
                color: Colors.teal.shade100,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // هنا تضيف منطق تأكيد التبرع
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'تأكيد التبرع',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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

// صفحة اختيار الأيتام
class OrphansListScreen extends StatelessWidget {
  final List<Map<String, String>> orphans = [
    {'name': 'أحمد', 'age': '10', 'image': 'images/ahmed.png'},
  //  {'name': 'سارة', 'age': '12', 'image': 'assets/sarah.jpg'},
    {'name': 'خالد', 'age': '9', 'image': 'images/khaleed.png'},
   // {'name': 'ليان', 'age': '2 mounth', 'image': 'images/layan.png'},
    //{'name': 'محمد', 'age': '11', 'image': 'assets/mohammed.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار يتيم')),
      body: ListView.builder(
        itemCount: orphans.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(orphans[index]['image']!, width: 50, height: 50),
            title: Text(orphans[index]['name']!),
            subtitle: Text('العمر: ${orphans[index]['age']}'),
            onTap: () {
              Navigator.pop(context, orphans[index]['name']);
            },
          );
        },
      ),
    );
  }
}
