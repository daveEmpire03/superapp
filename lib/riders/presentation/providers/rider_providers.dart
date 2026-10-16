import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/rider_job_entity.dart';

// -----------------------------------------------------------------------------
// Rider jobs list — the single source of truth for all rider data.
// -----------------------------------------------------------------------------

final riderJobsProvider =
    AsyncNotifierProvider<RiderJobsNotifier, List<RiderJobEntity>>(
      RiderJobsNotifier.new,
    );

class RiderJobsNotifier extends AsyncNotifier<List<RiderJobEntity>> {
  @override
  Future<List<RiderJobEntity>> build() {
    return ref.read(riderRepositoryProvider).getMyDeliveries();
  }

  /// Manually refetch (used by pull-to-refresh and after actions).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(riderRepositoryProvider).getMyDeliveries(),
    );
  }

  /// Advance or reject a delivery, then update the local list in place.
  /// Returns the updated entity so the caller can react if needed.
  Future<RiderJobEntity> updateStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? note,
    String? proofNote,
  }) async {
    final updated = await ref
        .read(riderRepositoryProvider)
        .updateStatus(
          deliveryId: deliveryId,
          status: status,
          note: note,
          proofNote: proofNote,
        );

    final current = state.asData?.value ?? const <RiderJobEntity>[];

    state = AsyncData([
      for (final job in current)
        if (job.id == deliveryId) updated else job,
    ]);

    return updated;
  }
}

// -----------------------------------------------------------------------------
// Derived selectors
// -----------------------------------------------------------------------------

/// A specific job by id, derived from the list. Returns null if not loaded yet
/// or not found. The list provider is the source of truth — the backend has
/// no separate rider detail endpoint.
final riderJobByIdProvider = Provider.family<RiderJobEntity?, String>((
  ref,
  id,
) {
  final jobs = ref.watch(riderJobsProvider).asData?.value;
  if (jobs == null) return null;

  for (final job in jobs) {
    if (job.id == id) return job;
  }

  return null;
});

/// Active deliveries only (not DELIVERED / REJECTED / CANCELLED).
final activeRiderJobsProvider = Provider<List<RiderJobEntity>>((ref) {
  final jobs = ref.watch(riderJobsProvider).asData?.value ?? const [];
  return jobs.where((j) => j.status.isActive).toList(growable: false);
});

/// Completed today's deliveries.
final completedTodayRiderJobsProvider = Provider<List<RiderJobEntity>>((ref) {
  final jobs = ref.watch(riderJobsProvider).asData?.value ?? const [];
  final now = DateTime.now();

  return jobs
      .where((j) {
        if (j.status != DeliveryStatus.delivered) return false;
        final deliveredAt = j.deliveredAt;
        if (deliveredAt == null) return false;
        final local = deliveredAt.toLocal();
        return local.year == now.year &&
            local.month == now.month &&
            local.day == now.day;
      })
      .toList(growable: false);
});
