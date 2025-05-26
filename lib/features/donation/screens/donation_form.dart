import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekfalninew/providers/donation_provider.dart';
import 'package:ekfalninew/models/donation_model.dart';

class DonationFormScreen extends ConsumerWidget {
  const DonationFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(donationFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تبرع'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Input
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixText: 'SR ',
              ),
              onChanged: (value) {
                ref.read(donationFormProvider.notifier)
                    .updateAmount(double.tryParse(value) ?? 0.0);
              },
            ),
            const SizedBox(height: 16),


            // Payment Method Selection
            DropdownButtonFormField<String>(
              value: formState['paymentMethod'],
              decoration: const InputDecoration(
                labelText: 'Payment Method',
              ),
              items: const [
                DropdownMenuItem(value: 'card', child: Text('Credit Card')),
                DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'wallet', child: Text('Digital Wallet')),
              ],
              onChanged: (value) {
                ref.read(donationFormProvider.notifier)
                    .updatePaymentMethod(value!);
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: () async {
                final donation = Donation(
                  amount: formState['amount'],
                  currency: 'SAR', // أو اجعلها جزء من الفورم إذا أردت
                  category: formState['category'],
                  status: 'pending',
                  createdAt: DateTime.now(), id: '', donorId: '', donorName: '', donationType: '',
                );

                await ref.read(donationListProvider.notifier)
                    .createDonation(donation);

                ref.read(donationFormProvider.notifier).resetForm();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم التبرع بنجاح')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('تبرع'),
            ),
          ],
        ),
      ),
    );
  }
}
