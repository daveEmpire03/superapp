import 'package:bokku_mart/core/constants/app_colors.dart';
import 'package:bokku_mart/riders/domain/entities/rider_job_entity.dart';
import 'package:bokku_mart/riders/presentation/providers/rider_providers.dart';
import 'package:bokku_mart/riders/screens/rider_status_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiderJobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;

  const RiderJobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<RiderJobDetailScreen> createState() =>
      _RiderJobDetailScreenState();
}

class _RiderJobDetailScreenState extends ConsumerState<RiderJobDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _advance(RiderJobEntity job, DeliveryStatus next) async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(riderJobsProvider.notifier)
          .updateStatus(deliveryId: job.id, status: next);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Marked as ${next.label}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _reject(RiderJobEntity job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject delivery?'),
        content: const Text(
          'This will remove the delivery from your queue and notify the store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(riderJobsProvider.notifier)
          .updateStatus(deliveryId: job.id, status: DeliveryStatus.rejected);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Delivery rejected')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(riderJobsProvider);
    final job = ref.watch(riderJobByIdProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Details')),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load: $e', textAlign: TextAlign.center),
          ),
        ),
        data: (_) {
          if (job == null) {
            return const Center(child: Text('Delivery not found.'));
          }
          return _Body(job: job);
        },
      ),
      bottomNavigationBar: job == null
          ? null
          : _ActionBar(
              job: job,
              isSubmitting: _isSubmitting,
              onAdvance: (next) => _advance(job, next),
              onReject: () => _reject(job),
            ),
    );
  }
}

class _Body extends StatelessWidget {
  final RiderJobEntity job;
  const _Body({required this.job});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _Hero(job: job),
        const SizedBox(height: 20),
        _InfoCard(
          title: 'Store',
          icon: Icons.storefront_outlined,
          rows: [_Kv('Name', job.storeName)],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Customer',
          icon: Icons.person_outline_rounded,
          rows: [_Kv('Name', job.customerName)],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Order',
          icon: Icons.receipt_long_outlined,
          rows: [
            _Kv('Reference', job.orderReference),
            _Kv('Order status', job.orderStatus),
          ],
        ),
        if (job.deliveryNote.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Delivery note',
            icon: Icons.sticky_note_2_outlined,
            rows: [_Kv('Note', job.deliveryNote)],
          ),
        ],
        if (job.proofNote.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Proof',
            icon: Icons.verified_outlined,
            rows: [_Kv('Proof', job.proofNote)],
          ),
        ],
        const SizedBox(height: 12),
        _TimelineCard(history: job.history),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final RiderJobEntity job;
  const _Hero({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfacePurple, AppColors.primarySoft],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.orderReference,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: job.status.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(job.status.icon, size: 14, color: job.status.color),
                    const SizedBox(width: 6),
                    Text(
                      job.status.label,
                      style: TextStyle(
                        color: job.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Placed ${_timeAgo(job.createdAt)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Kv> rows;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final row in rows) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    row.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value.isEmpty ? '—' : row.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Kv {
  final String key;
  final String value;
  const _Kv(this.key, this.value);
}

class _TimelineCard extends StatelessWidget {
  final List<DeliveryHistoryEntry> history;
  const _TimelineCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'History',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            Text(
              'No history yet.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            for (var i = 0; i < history.length; i++)
              _TimelineRow(entry: history[i], isLast: i == history.length - 1),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final DeliveryHistoryEntry entry;
  final bool isLast;

  const _TimelineRow({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.status.surface,
                  border: Border.all(color: entry.status.color, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.status.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (entry.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        entry.note,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _formatDateTime(entry.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final RiderJobEntity job;
  final bool isSubmitting;
  final Future<void> Function(DeliveryStatus) onAdvance;
  final VoidCallback onReject;

  const _ActionBar({
    required this.job,
    required this.isSubmitting,
    required this.onAdvance,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final next = job.nextAction;
    if (next == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitting)
            const SizedBox(
              height: 52,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onAdvance(next),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text('Mark as ${next.label}'),
              ),
            ),
          if (job.status == DeliveryStatus.assigned && !isSubmitting) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject delivery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} d ago';
}

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final mo = local.month.toString().padLeft(2, '0');
  return '$d/$mo/${local.year} · $h:$m';
}
