import 'package:bokku_mart/riders/domain/entities/rider_job_entity.dart';
import 'package:bokku_mart/riders/presentation/providers/rider_providers.dart';
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
        content: const Text('This will remove the delivery from your queue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
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
    // Watch the list provider so the detail stays reactive.
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

          return _Body(
            job: job,
            isSubmitting: _isSubmitting,
            onAdvance: (next) => _advance(job, next),
            onReject: () => _reject(job),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final RiderJobEntity job;
  final bool isSubmitting;
  final Future<void> Function(DeliveryStatus) onAdvance;
  final VoidCallback onReject;

  const _Body({
    required this.job,
    required this.isSubmitting,
    required this.onAdvance,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final next = job.nextAction;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Header(job: job),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Order',
          rows: [
            _Kv('Reference', job.orderReference),
            _Kv('Order status', job.orderStatus),
            _Kv('Store', job.storeName),
            _Kv('Customer', job.customerName),
          ],
        ),
        if (job.deliveryNote.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Delivery note',
            rows: [_Kv('Note', job.deliveryNote)],
          ),
        ],
        if (job.proofNote.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoCard(title: 'Proof', rows: [_Kv('Proof', job.proofNote)]),
        ],
        const SizedBox(height: 16),
        _TimelineCard(history: job.history),
        const SizedBox(height: 24),
        if (isSubmitting)
          const Center(child: CircularProgressIndicator())
        else if (next != null) ...[
          FilledButton.icon(
            onPressed: () => onAdvance(next),
            icon: const Icon(Icons.arrow_forward),
            label: Text('Mark as ${next.label}'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          if (job.status == DeliveryStatus.assigned) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close),
              label: const Text('Reject delivery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ] else
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No further actions for this delivery.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final RiderJobEntity job;
  const _Header({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.orderReference,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            job.status.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_Kv> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          for (final row in rows) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    row.key,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value.isEmpty ? '—' : row.value,
                    style: Theme.of(context).textTheme.bodyMedium,
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
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          if (history.isEmpty)
            Text(
              'No history yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final entry in history)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.status.label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (entry.note.isNotEmpty)
                            Text(
                              entry.note,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            entry.createdAt.toLocal().toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
