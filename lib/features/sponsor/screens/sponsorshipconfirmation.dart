import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekfalninew/features/sponsor/providers/sponsor_provider.dart';

class SponsorshipConfirmation extends ConsumerStatefulWidget {
  final String orphanName;
  final int duration;
  final double amount;
  final bool isRenewal;

  const SponsorshipConfirmation({
    required this.orphanName,
    required this.duration,
    required this.amount,
    this.isRenewal = false,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SponsorshipConfirmation> createState() => _SponsorshipConfirmationState();
}

class _SponsorshipConfirmationState extends ConsumerState<SponsorshipConfirmation> {
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

  bool _isProcessing = false;

  Future<void> _confirmSponsorship() async {
    setState(() => _isProcessing = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Add to sponsorship register based on type
      if (widget.isRenewal) {
        ref.read(sponsorNotifierProvider.notifier).addSponsorshipRenewal(
          orphanId: widget.orphanName,
          amount: widget.amount.toString(),
          duration: widget.duration,
          frequency: 'monthly',
        );
      } else {
        ref.read(sponsorNotifierProvider.notifier).addNewSponsorship(
          orphanId: widget.orphanName,
          amount: widget.amount.toString(),
          duration: widget.duration,
          frequency: 'monthly',
        );
      }

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.isRenewal ? 'تم تجديد الكفالة بنجاح' : 'تمت الكفالة بنجاح'),
            content: Text(
              widget.isRenewal
                  ? 'تم تجديد كفالة ${widget.orphanName} بنجاح لمدة ${widget.duration} شهر'
                  : 'تمت كفالة ${widget.orphanName} بنجاح لمدة ${widget.duration} شهر',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/mysponsor', // Navigate to sponsorships register
                    (route) => false,
                  );
                },
                child: const Text('عرض سجل الكفالات'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في عملية الكفالة: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isRenewal ? 'تأكيد تجديد الكفالة' : 'تأكيد الكفالة'),
          backgroundColor: Colors.teal,
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
                  onPressed: _isProcessing ? null : _confirmSponsorship,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : const Text(
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
