import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BankTransferPage extends StatefulWidget {
  const BankTransferPage({super.key});

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage> {
  File? _receiptImage;

  Future<void> _pickReceiptImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  void _sendReceipt() {
    if (_receiptImage != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("تم الإرسال"),
          content: const Text("تم إرسال إيصال الدفع بنجاح. شكرًا لتبرعك!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("حسنًا"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار إيصال الدفع أولاً')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('التحويل البنكي',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'يرجى التحويل إلى الحساب البنكي التالي:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.account_balance, color: Colors.teal),
                        title: Text('اسم البنك'),
                        subtitle: Text('البنك الأهلي السعودي'),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.numbers, color: Colors.teal),
                        title: Text('رقم الحساب'),
                        subtitle: SelectableText('123456789012345'),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.credit_card, color: Colors.teal),
                        title: Text('الآيبان'),
                        subtitle: SelectableText('SA0380000000608010167519'),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.teal),
                        title: Text('اسم المستفيد'),
                        subtitle: Text('جمعية الخير للتبرعات'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'بعد إجراء التحويل، يرجى إرسال إيصال الدفع على البريد التالي:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'donate@charity.org',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickReceiptImage,
                  icon: const Icon(Icons.upload_file,color: Colors.white,),
                  label: const Text('إرفاق إيصال الدفع',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_receiptImage != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'تم اختيار الإيصال:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _receiptImage!,
                        height: 200,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _sendReceipt,
                  icon: const Icon(Icons.send,color: Colors.white,),
                  label: const Text('إرسال الإيصال',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
