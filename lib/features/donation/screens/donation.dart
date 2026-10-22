import 'package:ekfalninew/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekfalninew/models/donation_model.dart';
import 'package:ekfalninew/providers/auth_provider.dart';
import 'package:ekfalninew/providers/donation_provider.dart';
import 'fooddonation.dart';
import 'clothesdonation.dart';
import 'donationschool.dart';
import 'package:ekfalninew/drawer/CustomDrawer.dart';
import 'package:ekfalninew/features/payment/screens/PayPal.dart';
import 'package:ekfalninew/features/payment/screens/CreditCard.dart';
import 'package:ekfalninew/features/payment/screens/BankTransfer.dart';


class donation extends ConsumerStatefulWidget {
  final String? projectTitle;
  final String? projectDescription;
  final String? donationType;

  const donation({
    super.key,
    this.projectTitle,
    this.projectDescription,
    this.donationType,
  });

  @override
  ConsumerState<donation> createState() => _donationState();
}

class _donationState extends ConsumerState<donation> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<String> _countryCodes = ['+967','+966', '+20', '+971', '+1', '+44', '+49'];
  String _selectedCountryCode = '+967';

  @override
  void initState() {
    super.initState();
    // Initialize form with default values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationFormProvider.notifier).resetForm();
      
      // If this is a project donation, set the category
      if (widget.donationType == 'project') {
        ref.read(donationFormProvider.notifier).updateCategory('project');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    final formState = ref.read(donationFormProvider);
    return formState['amount'] > 0 &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty;
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يرجى تعبئة جميع البيانات المطلوبة بشكل صحيح'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _processDonation(String paymentMethod) async {
    if (!_isFormValid()) {
      _showValidationError();
      return;
    }

    final formState = ref.read(donationFormProvider);
    final user = await ref.read(authProvider.future);

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to make a donation'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    final donation = Donation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: formState['amount'],
      currency: formState['currency'],
      donationType: widget.donationType ?? formState['donationType'],
      category: formState['category'].isEmpty ? 'general' : formState['category'],
      donorId: user.id,
      donorName: user.name,
      createdAt: DateTime.now(),
      status: 'pending',
      paymentMethod: paymentMethod,
      projectTitle: widget.projectTitle,
      projectDescription: widget.projectDescription,
    );

    try {
      await ref.read(donationListProvider.notifier).createDonation(donation);
      
      if (mounted) {
        switch (paymentMethod) {
          case 'credit_card':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreditCardPage(),
              ),
            );
            break;
          case 'paypal':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PayPalPage(),
              ),
            );
            break;
          case 'bank_transfer':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BankTransferPage(),
              ),
            );
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating donation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(donationFormProvider);
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.projectTitle ?? 'تبرع معنا',
            style: AppTheme.headingStyle.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/donation-cart'),
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              tooltip: 'سلة التبرعات',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/mydonat');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryColor),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'سجل التبرعات',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: const drawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.projectDescription != null) ...[
                _buildSection(
                  title: "تفاصيل المشروع",
                  child: Text(
                    widget.projectDescription!,
                    style: AppTheme.bodyStyle,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (widget.donationType != 'project') ...[
                _buildSection(
                  title: "اختر نوع التبرع",
                  child: Row(
                    children: [
                      Expanded(child: _donationTypeButton("مرة واحدة")),
                      const SizedBox(width: 12),
                      Expanded(child: _donationTypeButton("شهري")),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildSection(
                  title: "الفئات",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCategoryIcon(context, Icons.school, "مواد دراسية", () {
                        ref.read(donationFormProvider.notifier).updateCategory('school');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DonationSchoolScreen()));
                      }),
                      _buildCategoryIcon(context, Icons.checkroom, "ملابس", () {
                        ref.read(donationFormProvider.notifier).updateCategory('clothes');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DonationClothesScreen()));
                      }),
                      _buildCategoryIcon(context, Icons.food_bank, "مواد غذائية", () {
                        ref.read(donationFormProvider.notifier).updateCategory('food');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DonationFoodScreen()));
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildSection(
                title: "أدخل مبلغ التبرع",
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: AppTheme.inputDecoration("مثال: 100"),
                        textAlign: TextAlign.right,
                        onChanged: (value) {
                          final amount = double.tryParse(value);
                          if (amount != null) {
                            ref.read(donationFormProvider.notifier).updateAmount(amount);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: formState['currency'],
                        items: ['SR', '\$', 'YR'].map((currency) {
                          return DropdownMenuItem<String>(
                            value: currency,
                            child: Text(
                              currency,
                              textDirection: TextDirection.ltr,
                              style: AppTheme.bodyStyle,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(donationFormProvider.notifier).updateCurrency(value);
                          }
                        },
                        underline: Container(),
                        icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: "المعلومات الشخصية",
                child: Column(
                  children: [
                    _buildTextField("الاسم الكامل", _nameController),
                    const SizedBox(height: 12),
                    _buildTextField("البريد الإلكتروني", _emailController),
                    const SizedBox(height: 12),
                    _buildPhoneField(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: "طريقة الدفع",
                child: Row(
                  children: [
                    Expanded(child: _paymentMethodButton("Credit Card", () => _processDonation('credit_card'))),
                    const SizedBox(width: 12),
                    Expanded(child: _paymentMethodButton("PayPal", () => _processDonation('paypal'))),
                    const SizedBox(width: 12),
                    Expanded(child: _paymentMethodButton("Bank Transfer", () => _processDonation('bank_transfer'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _donationTypeButton(String label) {
    final formState = ref.watch(donationFormProvider);
    final bool isSelected = formState['donationType'] == (label == 'مرة واحدة' ? 'one-time' : 'monthly');

    return ElevatedButton(
      onPressed: () {
        ref.read(donationFormProvider.notifier).updateDonationType(
          label == 'مرة واحدة' ? 'one-time' : 'monthly'
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: const BorderSide(color: Colors.black),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(30),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCountryCode = value;
                    });
                  }
                },
                items: _countryCodes.map((code) {
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(code, textDirection: TextDirection.ltr),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: "رقم الجوال",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final formState = ref.watch(donationFormProvider);
    final isSelected = formState['category'] == label.toLowerCase();

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color: AppTheme.primaryColor, // لون دائم
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headingStyle,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
