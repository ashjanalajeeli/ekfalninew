import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekfalninew/providers/donation_provider.dart';
import 'package:ekfalninew/models/donation_model.dart';
import 'donation_form.dart';

class DonationListScreen extends ConsumerWidget {
  const DonationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(donationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: donationsAsync.when(
        data: (donations) => _buildDonationList(donations, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildDonationList(List<Donation> donations, WidgetRef ref) {
    if (donations.isEmpty) {
      return const Center(
        child: Text('No donations yet'),
      );
    }

    return ListView.builder(
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final donation = donations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('${donation.currency} ${donation.amount}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${donation.category}'),
                Text('Type: ${donation.donationType}'),
                Text('Status: ${donation.status}'),
              ],
            ),
            trailing: donation.status == 'pending'
                ? PopupMenuButton<String>(
                    onSelected: (String status) {
                      ref.read(donationListProvider.notifier).updateDonationStatus(
                            donation.id!,
                            status,
                          );
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'approved',
                        child: Text('Approve'),
                      ),
                      const PopupMenuItem(
                        value: 'rejected',
                        child: Text('Reject'),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
} 