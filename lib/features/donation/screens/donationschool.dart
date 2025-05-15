import 'package:flutter/material.dart';

class DonationSchoolScreen extends StatefulWidget {
  @override
  _DonationSchoolScreenState createState() => _DonationSchoolScreenState();
}

class _DonationSchoolScreenState extends State<DonationSchoolScreen> {
  final List<String> supplies = ['دفاتر', 'أقلام', 'حقائب مدرسية'];
  final Map<String, TextEditingController> controllers = {};
  String? selectedBeneficiary;
  String? selectedDelivery;

  @override
  void initState() {
    super.initState();
    for (var item in supplies) {
      controllers[item] = TextEditingController(text: '0');
    }
  }

  Widget buildSupplyItem(String item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.teal[100],
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لدعم اللغة العربية
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تبرع بالمواد الدراسية',style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text("المواد للتبرع", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ...supplies.map((item) => buildSupplyItem(item)).toList(),
              const SizedBox(height: 20),
              const Text("اختيار المستفيد", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              buildOption(
                value: 'يتيم: دعم تعليم سارة',
                groupValue: selectedBeneficiary ?? '',
                onChanged: (val) => setState(() => selectedBeneficiary = val),
                label: 'يتيم: دعم تعليم سارة',
                color: Colors.grey.shade300,
              ),
              buildOption(
                value: 'مشروع: دعم المدارس',
                groupValue: selectedBeneficiary ?? '',
                onChanged: (val) => setState(() => selectedBeneficiary = val),
                label: 'مشروع: دعم المدارس',
                color: Colors.grey.shade300,
              ),
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
                    // منطق تأكيد التبرع
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'تأكيد التبرع',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // ← تم تعديل اللون للأبيض
                    ),
                  ),                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
