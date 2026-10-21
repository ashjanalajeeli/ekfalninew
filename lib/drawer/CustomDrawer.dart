import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'help.dart';
import 'setting.dart';
import '../theme/app_theme.dart';

class drawer extends StatefulWidget {
  const drawer({super.key});

  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {
  String username = "Ashjan";
  String email = "ashjan@gmail.com";
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Ashjan";
      email = prefs.getString('email') ?? "ashjan@gmail.com";
      imagePath = prefs.getString('userImage');
    });
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userImage', imagePath!);
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      imagePath = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userImage');
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
          backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('اختيار صورة'),
              onTap: () {
                Navigator.pop(context);
                _selectImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('حذف الصورة'),
              onTap: () {
                Navigator.pop(context);
                _removeImage();
              },
            ),
          ],
        );
      },
    );
  }

  void _inviteFriends() {
    const String appLink = 'https://example.com/app'; // ← غيّر هذا الرابط إلى رابط تطبيقك الحقيقي
    Share.share(
      'مرحباً! 👋\nأنصحك بتحميل هذا التطبيق الرائع:\n$appLink',
      subject: 'انضم إليّ في هذا التطبيق!',
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // حذف البيانات المحفوظة
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: Colors.grey.shade100,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                accountName: Text(
                  username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(email),
                currentAccountPicture: GestureDetector(
                  onTap: _showImageOptions,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: imagePath != null
                        ? FileImage(File(imagePath!))
                        : const AssetImage("images/default_avatar.png") as ImageProvider,
                    child: imagePath == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildListTile(
                icon: Icons.settings,
                text: "الإعدادات",
                onTap: () {
                  Navigator.pushNamed(context, '/settingpage');
                },
              ),
              _buildListTile(
                icon: Icons.group_add,
                text: "دعوة الأصدقاء",
                onTap: _inviteFriends,
              ),
              _buildListTile(
                icon: Icons.help_outline,
                text: "مساعدة",
                onTap: () {
                  Navigator.pushNamed(context, '/helppage');
                },
              ),
              const Divider(),
              _buildListTile(
                icon: Icons.logout,
                text: "تسجيل الخروج",
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          color: AppTheme.textColor,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
