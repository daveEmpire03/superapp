import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/store_entity.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';

class StoreSelector extends StatelessWidget {
  const StoreSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        if (state is StoreLoading) {
          return const SizedBox(
            height: 48,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is StoreError) {
          return _StoreError(
            message: state.message,
          );
        }

        if (state is StoreLoaded) {
          return _SelectedStoreButton(
            selectedStore: state.selectedStore,
            onPressed: () {
              _showStoreBottomSheet(
                context,
                state,
              );
            },
          );
        }

        if (state is StoreLocationLoading) {
          return _SelectedStoreButton(
            selectedStore: state.selectedStore,
            onPressed: null,
            isLoading: true,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showStoreBottomSheet(
    BuildContext context,
    StoreLoaded state,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<StoreBloc>(),
          child: _StoreBottomSheet(
            initialState: state,
          ),
        );
      },
    );
  }
}

class _SelectedStoreButton extends StatelessWidget {
  final StoreEntity? selectedStore;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SelectedStoreButton({
    required this.selectedStore,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 22,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopping from',
                      style: theme.textTheme.labelSmall,
                    ),
                    Text(
                      selectedStore?.name ?? 'Select a store',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreBottomSheet extends StatefulWidget {
  final StoreLoaded initialState;

  const _StoreBottomSheet({
    required this.initialState,
  });

  @override
  State<_StoreBottomSheet> createState() => _StoreBottomSheetState();
}

class _StoreBottomSheetState extends State<_StoreBottomSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _findStoresNearMe() {
    context.read<StoreBloc>().add(
          const LoadStoresWithLocationEvent(),
        );
  }

  void _search(String value) {
    final bloc = context.read<StoreBloc>();
    final query = value.trim();

    if (query.isEmpty) {
      bloc.add(
        const LoadStoresEvent(),
      );
      return;
    }

    bloc.add(
      SearchStoresEvent(
        query: query,
      ),
    );
  }

  Future<void> _handleLocationAction(
    LocationExceptionType type,
  ) async {
    switch (type) {
      case LocationExceptionType.permissionDeniedForever:
        await Geolocator.openAppSettings();
        break;

      case LocationExceptionType.serviceDisabled:
        await Geolocator.openLocationSettings();
        break;

      case LocationExceptionType.permissionDenied:
      case LocationExceptionType.timeout:
      case LocationExceptionType.unavailable:
        if (!mounted) return;

        _findStoresNearMe();
        break;
    }
  }

  String _locationActionLabel(
    LocationExceptionType type,
  ) {
    switch (type) {
      case LocationExceptionType.permissionDeniedForever:
        return 'Open Settings';

      case LocationExceptionType.serviceDisabled:
        return 'Turn On Location';

      case LocationExceptionType.permissionDenied:
      case LocationExceptionType.timeout:
      case LocationExceptionType.unavailable:
        return 'Try Again';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Choose your store',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              16,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _search(value);
                setState(() {});
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search store, city or area',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
              ),
            ),
          ),
          BlocBuilder<StoreBloc, StoreState>(
            builder: (context, state) {
              final isLocating = state is StoreLocationLoading;

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLocating ? null : _findStoresNearMe,
                    icon: isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.near_me_outlined,
                          ),
                    label: Text(
                      isLocating
                          ? 'Finding nearby stores...'
                          : 'Find stores near me',
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<StoreBloc, StoreState>(
              builder: (context, state) {
                if (state is StoreLocationLoading) {
                  if (state.stores.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Stack(
                    children: [
                      _StoreList(
                        stores: state.stores,
                        selectedStore: state.selectedStore,
                      ),
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        child: IgnorePointer(
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (state is StoreLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is StoreError) {
                  return _StoreError(
                    message: state.message,
                  );
                }

                if (state is! StoreLoaded) {
                  return const SizedBox.shrink();
                }

                if (state.stores.isEmpty) {
                  return const Center(
                    child: Text(
                      'No stores found.',
                    ),
                  );
                }

                return Column(
                  children: [
                    if (state.locationMessage != null)
                      _LocationMessage(
                        message: state.locationMessage!,
                        exceptionType: state.locationExceptionType,
                        onAction: state.locationExceptionType == null
                            ? null
                            : () {
                                _handleLocationAction(
                                  state.locationExceptionType!,
                                );
                              },
                        actionLabel: state.locationExceptionType == null
                            ? null
                            : _locationActionLabel(
                                state.locationExceptionType!,
                              ),
                      ),
                    Expanded(
                      child: _StoreList(
                        stores: state.stores,
                        selectedStore: state.selectedStore,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationMessage extends StatelessWidget {
  final String message;
  final LocationExceptionType? exceptionType;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _LocationMessage({
    required this.message,
    this.exceptionType,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        12,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _locationIcon(),
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (onAction != null && actionLabel != null) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(
                          0,
                          32,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        actionLabel!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _locationIcon() {
    switch (exceptionType) {
      case LocationExceptionType.serviceDisabled:
        return Icons.location_disabled_outlined;

      case LocationExceptionType.permissionDenied:
      case LocationExceptionType.permissionDeniedForever:
        return Icons.location_off_outlined;

      case LocationExceptionType.timeout:
        return Icons.timer_off_outlined;

      case LocationExceptionType.unavailable:
      case null:
        return Icons.location_off_outlined;
    }
  }
}

class _StoreList extends StatelessWidget {
  final List<StoreEntity> stores;
  final StoreEntity? selectedStore;

  const _StoreList({
    required this.stores,
    required this.selectedStore,
  });

  @override
  Widget build(BuildContext context) {
    final storesWithDistance = stores
        .where(
          (store) => store.distanceKm != null,
        )
        .toList()
      ..sort(
        (a, b) => a.distanceKm!.compareTo(
          b.distanceKm!,
        ),
      );

    final hasDistance = storesWithDistance.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        32,
      ),
      children: [
        if (hasDistance) ...[
          Text(
            'Near you',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...storesWithDistance.take(5).map(
                (store) => _StoreTile(
                  store: store,
                  isSelected: selectedStore?.id == store.id,
                ),
              ),
          const SizedBox(height: 24),
        ],
        Text(
          'All stores',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...stores.map(
          (store) => _StoreTile(
            store: store,
            isSelected: selectedStore?.id == store.id,
          ),
        ),
      ],
    );
  }
}

class _StoreTile extends StatelessWidget {
  final StoreEntity store;
  final bool isSelected;

  const _StoreTile({
    required this.store,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        child: Icon(
          Icons.storefront_outlined,
        ),
      ),
      title: Text(
        store.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.fullAddress,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (store.distanceKm != null)
            Text(
              '${store.distanceKm!.toStringAsFixed(1)} km away',
            ),
        ],
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(
              Icons.chevron_right,
            ),
      onTap: () {
        context.read<StoreBloc>().add(
              SelectStoreEvent(
                store.id,
              ),
            );

        Navigator.of(context).pop();
      },
    );
  }
}

class _StoreError extends StatelessWidget {
  final String message;

  const _StoreError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.store_mall_directory_outlined,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.read<StoreBloc>().add(
                      const LoadStoresEvent(),
                    );
              },
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
