import 'package:flutter/material.dart';

class DonationFoodScreen extends StatefulWidget {
  @override
  _DonationFoodScreenState createState() => _DonationFoodScreenState();
}

class _DonationFoodScreenState extends State<DonationFoodScreen> {
  final TextEditingController additionalDetailsController = TextEditingController();
  List<Map<String, TextEditingController>> foodItems = [];
  List<Map<String, dynamic>> donationLog = [];

  @override
  void initState() {
    super.initState();
    _addFoodItem();
  }

  void _addFoodItem() {
    setState(() {
      foodItems.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(text: '1'),
      });
    });
  }

  void _removeFoodItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد أنك تريد حذف هذا العنصر؟'),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                foodItems.removeAt(index);
              });
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف العنصر'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDonation() {
    List<Map<String, dynamic>> donatedItems = foodItems.map((item) {
      return {
        'name': item['name']?.text ?? '',
        'quantity': int.tryParse(item['quantity']?.text ?? '1') ?? 1,
      };
    }).toList();

    Map<String, dynamic> donationRecord = {
      'type': 'مواد غذائية',
      'items': donatedItems,
      'notes': additionalDetailsController.text,
      'status': 'قيد التوصيل',
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      donationLog.add(donationRecord);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال طلب التبرع، بانتظار الاستلام.'),
        backgroundColor: Colors.green,
      ),
    );

    print('سجل التبرعات: $donationLog');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تبرع بالمواد الغذائية',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("نوع التبرع", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("مواد غذائية", style: TextStyle(color: Colors.grey[800])),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            'images/food.png',
                            height: 200,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("المواد الغذائية", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        ...foodItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          var item = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: item['name'],
                                    textDirection: TextDirection.rtl,
                                    decoration: InputDecoration(
                                      hintText: "اسم المادة (مثلاً: بيض)",
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      const Text("الكمية: "),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: DropdownButton<int>(
                                            isExpanded: true,
                                            underline: SizedBox(),
                                            value: int.tryParse(item['quantity']!.text) ?? 1,
                                            onChanged: (value) {
                                              setState(() {
                                                item['quantity']!.text = value.toString();
                                              });
                                            },
                                            items: List.generate(100, (i) => i + 1)
                                                .map((num) => DropdownMenuItem(
                                              value: num,
                                              child: Text(num.toString()),
                                            ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeFoodItem(index),
                                )
                              ],
                            ),
                          );
                        }),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _addFoodItem,
                            icon: Icon(Icons.add),
                            label: Text("إضافة عنصر"),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text("ملاحظات إضافية", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: additionalDetailsController,
                          textDirection: TextDirection.rtl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "أدخل أي معلومات إضافية",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              bool isValid = foodItems.any((item) =>
                              item['name']!.text.trim().isNotEmpty &&
                                  int.tryParse(item['quantity']!.text) != null &&
                                  int.parse(item['quantity']!.text) > 0);

                              if (!isValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("يرجى إضافة مادة غذائية واحدة على الأقل مع تحديد الكمية."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              _confirmDonation();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'تأكيد التبرع',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
