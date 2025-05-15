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
        title: const Text('Make a Donation'),
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
                labelText: 'Amount',
                prefixText: 'SR ',
              ),
              onChanged: (value) {
                ref.read(donationFormProvider.notifier)
                    .updateAmount(double.tryParse(value) ?? 0.0);
              },
            ),
            const SizedBox(height: 16),

            // Donation Type Selection
            DropdownButtonFormField<String>(
              value: formState['donationType'],
              decoration: const InputDecoration(
                labelText: 'Donation Type',
              ),
              items: const [
                DropdownMenuItem(value: 'one-time', child: Text('One Time')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) {
                ref.read(donationFormProvider.notifier)
                    .updateDonationType(value!);
              },
            ),
            const SizedBox(height: 16),

            // Category Selection
            DropdownButtonFormField<String>(
              value: formState['category'].isEmpty ? null : formState['category'],
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: const [
                DropdownMenuItem(value: 'food', child: Text('Food')),
                DropdownMenuItem(value: 'clothes', child: Text('Clothes')),
                DropdownMenuItem(value: 'education', child: Text('Education')),
                DropdownMenuItem(value: 'medical', child: Text('Medical')),
              ],
              onChanged: (value) {
                ref.read(donationFormProvider.notifier)
                    .updateCategory(value!);
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
                  donationType: formState['donationType'],
                  category: formState['category'],
                  status: 'pending',
                  createdAt: DateTime.now(), id: '', donorId: '', donorName: '',
                );

                await ref.read(donationListProvider.notifier)
                    .createDonation(donation);

                ref.read(donationFormProvider.notifier).resetForm();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donation submitted successfully')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit Donation'),
            ),
          ],
        ),
      ),
    );
  }
}
