import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String email = _emailController.text;
      final String message = _messageController.text;

      final String fullMessage = '''
الاسم: $name
البريد: $email

الرسالة:
$message
''';

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'donate@charity.org', // غيّره إلى بريدك
        queryParameters: {
          'subject': 'طلب مساعدة من التطبيق',
          'body': fullMessage,
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق البريد')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مساعدة',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 70, color: Colors.teal),
                const SizedBox(height: 20),
                const Text(
                  'نموذج التواصل',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'يرجى تعبئة النموذج أدناه وسنقوم بالرد عليك في أقرب وقت ممكن.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty || !value.contains('@')
                      ? 'الرجاء إدخال بريد صحيح'
                      : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'الرسالة',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) => value!.isEmpty ? 'اكتب رسالتك هنا' : null,
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: _sendEmail,
                  icon: const Icon(Icons.send,color: Colors.white,),
                  label: const Text('إرسال',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
