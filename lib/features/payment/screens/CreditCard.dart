import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekfalninew/features/donation/providers/donation_provider.dart';

class CreditCardPage extends ConsumerStatefulWidget {
  const CreditCardPage({super.key});

  @override
  ConsumerState<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends ConsumerState<CreditCardPage> {
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isCVVHidden = true;
  String _cardType = '';
  bool _isProcessing = false;
  String? _amount;
  String? _donationType;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_detectCardType);
    // Get amount and donation type from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _amount = args['amount'] as String?;
          _donationType = args['donationType'] as String?;
        });
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_detectCardType);
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _detectCardType() {
    final number = _cardNumberController.text;
    setState(() {
      if (number.startsWith('4')) {
        _cardType = 'Visa';
      } else if (number.startsWith('51') ||
          number.startsWith('52') ||
          number.startsWith('53') ||
          number.startsWith('54') ||
          number.startsWith('55')) {
        _cardType = 'MasterCard';
      } else {
        _cardType = '';
      }
    });
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.length != 16) {
      return 'رقم البطاقة يجب أن يتكون من 16 رقم';
    }
    if (!value.startsWith('4') &&
        !(value.startsWith('51') ||
            value.startsWith('52') ||
            value.startsWith('53') ||
            value.startsWith('54') ||
            value.startsWith('55'))) {
      return 'نوع البطاقة غير مدعوم. فقط Visa و MasterCard مسموح بهما';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.length != 3) {
      return 'CVV يجب أن يتكون من 3 أرقام';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || !RegExp(r"^(0[1-9]|1[0-2])\/\d{2}$").hasMatch(value)) {
      return 'تاريخ غير صالح. استخدم MM/YY';
    }
    return null;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate() || _amount == null) return;

    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Add donation to register
      ref.read(donationProvider.notifier).addFinancialDonation(
        amount: double.parse(_amount!),
        campaignId: '',
        paymentMethod: 'بطاقة ائتمان',
      );

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تم الدفع بنجاح'),
            content: const Text('تم تسجيل تبرعك بنجاح. شكراً لك!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/mydonat', // Navigate to donations register
                    (route) => false,
                  );
                },
                child: const Text('عرض سجل التبرعات'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في عملية الدفع: $e')),
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
          title: const Text('الدفع عبر البطاقة', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_cardType.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'نوع البطاقة: $_cardType',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'رقم البطاقة',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateCardNumber,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم على البطاقة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الانتهاء',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            if (text.length == 2 && !text.contains('/')) {
                              return TextEditingValue(
                                text: '${text}/',
                                selection: TextSelection.collapsed(offset: 3),
                              );
                            }
                            return newValue;
                          }),
                        ],
                        validator: _validateExpiryDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isCVVHidden ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isCVVHidden = !_isCVVHidden;
                              });
                            },
                          ),
                        ),
                        obscureText: _isCVVHidden,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validateCVV,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (_amount != null)
                  Text(
                    'المبلغ: $_amount ريال',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator()
                        : const Text('إتمام الدفع', style: TextStyle(color: Colors.white)),
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
