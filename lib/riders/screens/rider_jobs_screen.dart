import 'package:bokku_mart/riders/presentation/providers/rider_providers.dart';
import 'package:bokku_mart/riders/screens/rider_job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RiderJobsScreen extends ConsumerStatefulWidget {
  const RiderJobsScreen({super.key});

  @override
  ConsumerState<RiderJobsScreen> createState() => _RiderJobsScreenState();
}

class _RiderJobsScreenState extends ConsumerState<RiderJobsScreen> {
  bool _showActiveOnly = true;

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(riderJobsProvider);
    final active = ref.watch(activeRiderJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(riderJobsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Active')),
                ButtonSegment(value: false, label: Text('All')),
              ],
              selected: {_showActiveOnly},
              onSelectionChanged: (s) =>
                  setState(() => _showActiveOnly = s.first),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(riderJobsProvider.notifier).refresh(),
              child: jobsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.read(riderJobsProvider.notifier).refresh(),
                ),
                data: (all) {
                  final jobs = _showActiveOnly ? active : all;

                  if (jobs.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No deliveries to show.')),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final job = jobs[i];
                      return RiderJobCard(
                        job: job,
                        onTap: () => context.go('/rider/jobs/${job.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
