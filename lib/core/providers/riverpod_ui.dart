import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef StateChanged<T> = void Function(BuildContext context, T state);
typedef StateWidgetBuilder<T> = Widget Function(BuildContext context, T state);
typedef StatePredicate<T> = bool Function(T previous, T current);

/// Stateless bridge for the existing UI while BLoC is removed.
/// These widgets only use Riverpod; they do not instantiate BLoCs.
class RiverpodBuilder<T> extends ConsumerWidget {
  const RiverpodBuilder({
    super.key,
    required this.provider,
    required this.builder,
  });

  final ProviderListenable<T> provider;
  final StateWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref.watch(provider));
  }
}

class RiverpodListener<T> extends ConsumerWidget {
  const RiverpodListener({
    super.key,
    required this.provider,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  final ProviderListenable<T> provider;
  final StateChanged<T> listener;
  final Widget child;
  final StatePredicate<T>? listenWhen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<T>(provider, (previous, next) {
      if (previous != null && !(listenWhen?.call(previous, next) ?? true)) {
        return;
      }
      listener(context, next);
    });
    return child;
  }
}

class RiverpodConsumer<T> extends ConsumerWidget {
  const RiverpodConsumer({
    super.key,
    required this.provider,
    required this.listener,
    required this.builder,
    this.listenWhen,
  });

  final ProviderListenable<T> provider;
  final StateChanged<T> listener;
  final StateWidgetBuilder<T> builder;
  final StatePredicate<T>? listenWhen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<T>(provider, (previous, next) {
      if (previous != null && !(listenWhen?.call(previous, next) ?? true)) {
        return;
      }
      listener(context, next);
    });
    return builder(context, ref.watch(provider));
  }
}
