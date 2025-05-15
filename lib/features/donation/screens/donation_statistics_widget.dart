import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekfalninew/providers/donation_provider.dart';

class DonationStatisticsWidget extends ConsumerWidget {
  const DonationStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(donationStatisticsProvider);

    return statisticsAsync.when(
      data: (statistics) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donation Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatisticRow(
                'Total Donations',
                'SR ${statistics['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
              ),
              _buildStatisticRow(
                'Total Count',
                '${statistics['totalCount'] ?? 0}',
              ),
              const Divider(),
              const Text(
                'By Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildCategoryStats(statistics['byCategory'] ?? {}),
              const Divider(),
              const Text(
                'By Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildStatusStats(statistics['byStatus'] ?? {}),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryStats(Map<String, dynamic> categoryStats) {
    return categoryStats.entries.map((entry) {
      return _buildStatisticRow(
        entry.key,
        'SR ${entry.value.toStringAsFixed(2)}',
      );
    }).toList();
  }

  List<Widget> _buildStatusStats(Map<String, dynamic> statusStats) {
    return statusStats.entries.map((entry) {
      return _buildStatisticRow(
        entry.key,
        entry.value.toString(),
      );
    }).toList();
  }
} 