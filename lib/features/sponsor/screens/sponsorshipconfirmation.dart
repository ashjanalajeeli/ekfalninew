import 'package:flutter/material.dart';

class SponsorshipConfirmation extends StatefulWidget {
  final String orphanName;
  final int duration;
  final int amount;

  const SponsorshipConfirmation({
    Key? key,
    required this.orphanName,
    required this.duration,
    required this.amount,
  }) : super(key: key);

  @override
  _SponsorshipConfirmationState createState() => _SponsorshipConfirmationState();
}

class _SponsorshipConfirmationState extends State<SponsorshipConfirmation> {
  final TextEditingController arabicNameController = TextEditingController();
  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController residenceController = TextEditingController();
  final TextEditingController emailController = TextEditingController(); // <-- اضفت الكنترولر للبريد
  bool agreedToTerms = false;

  String selectedCountryCode = '+967'; // الافتراضي اليمن

  final List<String> countryCodes = [
    '+966', // السعودية
    '+971', // الإمارات
    '+965', // الكويت
    '+967', // اليمن
    '+968', // عمان
    '+974', // قطر
    '+973', // البحرين
    '+20',  // مصر
    '+962', // الأردن
    '+964', // العراق
    '+961', // لبنان
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تأكيد الكفالة', style: TextStyle(color: Colors.white)),
          backgroundColor:Colors.teal,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.volunteer_activism,
                  size: 100,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "تفاصيل الكفالة:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              buildDetailRow("اسم اليتيم:", widget.orphanName),
              buildDetailRow("مدة الكفالة:", "${widget.duration} شهور"),
              buildDetailRow("المبلغ الشهري:", "\$${widget.amount}"),
              const SizedBox(height: 20),
              buildTextField(controller: arabicNameController, label: "الاسم بالعربي"),
              const SizedBox(height: 20),
              buildTextField(controller: englishNameController, label: "الاسم الكامل بالإنجليزي"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCountryCode,
                        underline: const SizedBox(),
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        items: countryCodes.map((code) {
                          return DropdownMenuItem(
                            value: code,
                            child: Text(code),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: buildTextField(
                      controller: phoneController,
                      label: "رقم الجوال",
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              buildTextField(
                controller: emailController,
                label: "البريد الإلكتروني", // <-- اضفت خانة الايميل
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              buildTextField(controller: idController, label: "رقم الهوية / جواز السفر"),
              const SizedBox(height: 20),
              buildTextField(controller: residenceController, label: "مكان الإقامة"),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('أوافق على الشروط والأحكام'),
                value: agreedToTerms,
                onChanged: (bool? value) {
                  setState(() {
                    agreedToTerms = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (agreedToTerms &&
                        arabicNameController.text.isNotEmpty &&
                        englishNameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty &&
                        emailController.text.isNotEmpty && // <-- تأكد من الايميل
                        idController.text.isNotEmpty &&
                        residenceController.text.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تأكيد الكفالة بنجاح')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى تعبئة جميع الحقول والموافقة على الشروط')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "تأكيد الكفالة",
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

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({required TextEditingController controller, required String label, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
    );
  }
}
