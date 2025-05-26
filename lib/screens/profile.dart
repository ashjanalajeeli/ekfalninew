import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import 'package:ekfalninew/screens/homepage.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await ref.read(authProvider.future);
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        if (user.profileImage != null) {
          _imageFile = File(user.profileImage!); // استخدم ! فقط بعد التحقق
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update user profile
      await ref.read(authProvider.notifier).updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        profileImage: _imageFile?.path,
      );

      // Update password if provided
      if (_newPasswordController.text.isNotEmpty) {
        await ref.read(authProvider.notifier).updatePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
        );


        //  التنقل إلى الصفحة الرئيسية بعد الحفظ
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider).languageCode == 'ar';
    final tr = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: isArabic ? TextDirection.ltr: TextDirection.rtl ,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.translate('الملف الشخصي')),
          leading: isArabic ? null : BackButton(),
          actions: [
            if (isArabic) BackButton(),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage('images/default_avatar.png')
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: tr.translate('الاسم الكامل'),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.translate('الاسم مطلوب');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: tr.translate('البريد الإلكتروني'),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.translate('البريد الإلكتروني مطلوب');
                    }
                    if (!value.contains('@')) {
                      return tr.translate('يرجى إدخال بريد إلكتروني صحيح');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ExpansionTile(
                  title: Text(tr.translate('تغيير كلمة المرور')),
                  children: [
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: tr.translate('كلمة المرور الحالية'),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                 : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: tr.translate('كلمة المرور الجديدة'),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 6) {
                            return tr.translate('يجب أن تكون كلمة المرور 6 أحرف على الأقل');
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: tr.translate('تأكيد كلمة المرور'),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (_newPasswordController.text.isNotEmpty &&
                            value != _newPasswordController.text) {
                          return tr.translate('كلمات المرور غير متطابقة');
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(tr.translate('حفظ التغييرات')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 