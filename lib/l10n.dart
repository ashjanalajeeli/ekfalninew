import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = {
    'en': {
      'settings': 'Settings',
      'change_language': 'Change Language',
      'profile': 'Profile',
      'enable_notifications': 'Enable Notifications',
      'dark_mode': 'Dark Mode',
      'logout': 'Logout',
      'select_language': 'Select Language',
      'name': 'Full Name',
      'email': 'Email Address',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_password': 'Confirm Password',
      'change_password': 'Change Password',
      'save_changes': 'Save Changes',
      'name_required': 'Name is required',
      'email_required': 'Email is required',
      'invalid_email': 'Please enter a valid email',
      'password_too_short': 'Password must be at least 6 characters',
      'passwords_dont_match': 'Passwords do not match',
      // Home screen translations
      'home': 'Home',
      'featured_project': 'Featured Project',
      'featured_description': 'Help us make a difference in someone\'s life today',
      'donate_now': 'Donate Now',
      'sponsor_now': 'Sponsor Now',
      'school_bags': 'School Bags',
      'clothes': 'Clothes',
      'orphan_sponsorship': 'Orphan Sponsorship',
      'currency': 'SR',
      'current_amount': 'Current Amount',
      'target_amount': 'Target Amount',
    },
    'ar': {
      'settings': 'الإعدادات',
      'change_language': 'تغيير اللغة',
      'profile': 'الملف الشخصي',
      'enable_notifications': 'تفعيل الإشعارات',
      'dark_mode': 'الوضع الداكن',
      'logout': 'تسجيل الخروج',
      'select_language': 'اختر اللغة',
      'name': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_password': 'تأكيد كلمة المرور',
      'change_password': 'تغيير كلمة المرور',
      'save_changes': 'حفظ التغييرات',
      'name_required': 'الاسم مطلوب',
      'email_required': 'البريد الإلكتروني مطلوب',
      'invalid_email': 'يرجى إدخال بريد إلكتروني صحيح',
      'password_too_short': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'passwords_dont_match': 'كلمات المرور غير متطابقة',
      // Home screen translations
      'home': 'الصفحة الرئيسية',
      'featured_project': 'مشروع مميز',
      'featured_description': 'ساعدنا في إحداث فرق في حياة شخص ما اليوم',
      'donate_now': 'تبرع الآن',
      'sponsor_now': 'اكفل الآن',
      'school_bags': 'حقائب مدرسية',
      'clothes': 'ملابس',
      'orphan_sponsorship': 'كفالة يتيم',
      'currency': 'ريال',
      'current_amount': 'المبلغ الحالي',
      'target_amount': 'المبلغ المستهدف',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
