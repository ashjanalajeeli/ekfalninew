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
  const donation({super.key});

  @override
  ConsumerState<donation> createState() => _donationState();
}

class _donationState extends ConsumerState<donation> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<String> _countryCodes = ['+966', '+20', '+971', '+1', '+44', '+49'];
  String _selectedCountryCode = '+966';

  @override
  void initState() {
    super.initState();
    // Initialize form with default values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationFormProvider.notifier).resetForm();
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
      donationType: formState['donationType'],
      category: formState['category'].isEmpty ? 'general' : formState['category'],
      donorId: user.id,
      donorName: user.name,
      createdAt: DateTime.now(),
      status: 'pending',
      paymentMethod: paymentMethod,
    );

    try {
      await ref.read(donationListProvider.notifier).createDonation(donation);
      
      if (mounted) {
        switch (paymentMethod) {
          case 'credit_card':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditCardPage()));
            break;
          case 'paypal':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PayPalPage()));
            break;
          case 'bank_transfer':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BankTransferPage()));
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('تبرع معنا', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          elevation: 0,
          centerTitle: true,
        ),
        endDrawer: const drawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 20),
              const Text("اختر نوع التبرع", textAlign: TextAlign.right, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _donationTypeButton("مرة واحدة")),
                  const SizedBox(width: 10),
                  Expanded(child: _donationTypeButton("شهري")),
                ],
              ),
              const SizedBox(height: 20),
              const Text("الفئات", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
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
              const SizedBox(height: 20),
              const Text("أدخل مبلغ التبرع", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "مثال: 100",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        final amount = double.tryParse(value);
                        if (amount != null) {
                          ref.read(donationFormProvider.notifier).updateAmount(amount);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: formState['currency'],
                    items: ['SR', '\$', 'YR'].map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency, textDirection: TextDirection.ltr),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(donationFormProvider.notifier).updateCurrency(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("المعلومات الشخصية", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTextField("الاسم الكامل", _nameController),
              _buildTextField("البريد الإلكتروني", _emailController),
              _buildPhoneField(),
              const SizedBox(height: 20),
              const Text("طريقة الدفع", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _paymentMethodButton("Credit Card", () => _processDonation('credit_card'))),
                  const SizedBox(width: 10),
                  Expanded(child: _paymentMethodButton("PayPal", () => _processDonation('paypal'))),
                  const SizedBox(width: 10),
                  Expanded(child: _paymentMethodButton("Bank Transfer", () => _processDonation('bank_transfer'))),
                ],
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
        backgroundColor: isSelected ? Colors.teal : Colors.white,
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
            color: isSelected ? Colors.teal : Colors.grey,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.teal : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
