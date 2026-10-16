import 'package:bokku_mart/core/constants/app_colors.dart';
import 'package:bokku_mart/riders/domain/entities/rider_job_entity.dart';
import 'package:bokku_mart/riders/presentation/providers/rider_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Range { today, week, all }

class RiderEarningsScreen extends ConsumerStatefulWidget {
  const RiderEarningsScreen({super.key});

  @override
  ConsumerState<RiderEarningsScreen> createState() =>
      _RiderEarningsScreenState();
}

class _RiderEarningsScreenState extends ConsumerState<RiderEarningsScreen> {
  _Range _range = _Range.today;

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(riderJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load: $e', textAlign: TextAlign.center),
          ),
        ),
        data: (all) {
          final delivered =
              all.where((j) => j.status == DeliveryStatus.delivered).toList()
                ..sort(
                  (a, b) => (b.deliveredAt ?? b.updatedAt).compareTo(
                    a.deliveredAt ?? a.updatedAt,
                  ),
                );

          final filtered = _filter(delivered, _range);

          return RefreshIndicator(
            onRefresh: () => ref.read(riderJobsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _RangeBar(
                  value: _range,
                  onChanged: (v) => setState(() => _range = v),
                ),
                const SizedBox(height: 16),
                _SummaryCard(range: _range, count: filtered.length),
                const SizedBox(height: 24),
                Text(
                  'Recent deliveries',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _EarningsEmpty()
                else
                  for (final job in filtered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DeliveryRow(job: job),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<RiderJobEntity> _filter(List<RiderJobEntity> input, _Range range) {
    final now = DateTime.now();
    switch (range) {
      case _Range.today:
        return input.where((j) {
          final t = (j.deliveredAt ?? j.updatedAt).toLocal();
          return t.year == now.year && t.month == now.month && t.day == now.day;
        }).toList();
      case _Range.week:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final startDay = DateTime(start.year, start.month, start.day);
        return input
            .where(
              (j) => (j.deliveredAt ?? j.updatedAt).toLocal().isAfter(
                startDay.subtract(const Duration(seconds: 1)),
              ),
            )
            .toList();
      case _Range.all:
        return input;
    }
  }
}

class _RangeBar extends StatelessWidget {
  final _Range value;
  final ValueChanged<_Range> onChanged;

  const _RangeBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (final r in _Range.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(r),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: value == r ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    switch (r) {
                      _Range.today => 'Today',
                      _Range.week => 'This week',
                      _Range.all => 'All time',
                    },
                    style: TextStyle(
                      color: value == r
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _Range range;
  final int count;

  const _SummaryCard({required this.range, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Completed deliveries',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            switch (range) {
              _Range.today => 'today',
              _Range.week => 'this week',
              _Range.all => 'all time',
            },
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  final RiderJobEntity job;
  const _DeliveryRow({required this.job});

  @override
  Widget build(BuildContext context) {
    final when = job.deliveredAt ?? job.updatedAt;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.successSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.orderReference,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.storeName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _shortDate(when),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EarningsEmpty extends StatelessWidget {
  const _EarningsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Nothing to show yet',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete deliveries to see them here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

String _shortDate(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  return '$d/$m';
}
