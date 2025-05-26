import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sponsor_provider.dart';

class mysponsor extends ConsumerStatefulWidget {
  const mysponsor({super.key});

  @override
  ConsumerState<mysponsor> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends ConsumerState<mysponsor> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Load sponsorships when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sponsorNotifierProvider.notifier).loadSponsorships();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      if (!_showScrollToTop) setState(() => _showScrollToTop = true);
    } else {
      if (_showScrollToTop) setState(() => _showScrollToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch sponsorships to auto-refresh when they change
    final sponsorState = ref.watch(sponsorNotifierProvider);
    final sponsorships = sponsorState.sponsorships;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('سجل الكفالات'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              mini: true,
              child: const Icon(Icons.arrow_upward),
            ).animate().fade().scale()
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic
          await ref.read(sponsorNotifierProvider.notifier).loadSponsorships();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileSection(context),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'سجل الكفالات',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sponsorship = sponsorships[index];
                    return DonationCard(
                      title: sponsorship['title'] as String? ?? '',
                      date: sponsorship['date'] as String? ?? '',
                      amount: (sponsorship['amount'] as num?)?.toString() ?? '0',
                      status: sponsorship['status'] as String? ?? '',
                      sponsorshipType: sponsorship['type'] as String? ?? '',
                      details: sponsorship['details'] as String?,
                      index: index,
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 * index),
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  childCount: sponsorships.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Hero(
            tag: 'profile_image',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/images/mysponsor.jpg'),
              ),
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 16),
          Text(
            'ashjan alajeeli',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'حضرموت، اليمن',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 4),
          Text(
            'انضم منذ 2019',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 20),
          _buildSponsorBadge(context),
          const SizedBox(height: 20),
          _buildDonationStats(context),
        ],
      ),
    );
  }

  Widget _buildSponsorBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.volunteer_activism,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'كفيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    ).animate().scale(
      delay: 500.ms,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildDonationStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(context, '12', 'تبرع'),
        _buildStatItem(context, '\$1,200', 'المجموع'),
        _buildStatItem(context, '3', 'مشاريع'),
      ],
    ).animate().fadeIn(delay: 600.ms).slideX(
      begin: 0.2,
      end: 0,
      curve: Curves.easeOutCubic,
      duration: const Duration(milliseconds: 800),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

mixin sponsorProvider {
  late ProviderListenable notifier;
}

class DonationCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String status;
  final String? details;
  final String sponsorshipType;
  final int index;

  const DonationCard({
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.sponsorshipType,
    this.details,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          // Show sponsorship details in a dialog
          if (details != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التاريخ: $date'),
                    const SizedBox(height: 8),
                    Text('المبلغ: $amount'),
                    const SizedBox(height: 8),
                    Text('الحالة: $status'),
                    if (details != null) ...[
                      const SizedBox(height: 8),
                      Text('التفاصيل: $details'),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  sponsorshipType == 'renewal' ? Icons.autorenew : Icons.volunteer_activism,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (details != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
