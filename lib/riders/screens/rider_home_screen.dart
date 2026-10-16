import 'package:bokku_mart/features/auth/presentation/bloc/auth_state.dart';
import 'package:bokku_mart/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:bokku_mart/riders/presentation/providers/rider_providers.dart';
import 'package:bokku_mart/riders/screens/rider_job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RiderHomeScreen extends ConsumerWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState is Authenticated ? authState.user : null;

    final jobsAsync = ref.watch(riderJobsProvider);
    final activeJobs = ref.watch(activeRiderJobsProvider);
    final completedToday = ref.watch(completedTodayRiderJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(riderJobsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(riderJobsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GreetingCard(name: user?.firstName ?? 'Rider'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Active',
                    value: '${activeJobs.length}',
                    icon: Icons.local_shipping_outlined,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Completed today',
                    value: '${completedToday.length}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active deliveries',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.go('/rider/jobs'),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            jobsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _ErrorBlock(
                message: e.toString(),
                onRetry: () => ref.read(riderJobsProvider.notifier).refresh(),
              ),
              data: (_) {
                if (activeJobs.isEmpty) {
                  return const _EmptyBlock(
                    message: 'No active deliveries right now.',
                  );
                }
                return Column(
                  children: [
                    for (final job in activeJobs.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RiderJobCard(
                          job: job,
                          onTap: () => context.go('/rider/jobs/${job.id}'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  const _GreetingCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String message;
  const _EmptyBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      alignment: Alignment.center,
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
