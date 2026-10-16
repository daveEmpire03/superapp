import 'package:bokku_mart/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class RouterRefresh extends ChangeNotifier {
  RouterRefresh(ProviderContainer container) {
    _sub = container.listen<AuthState>(authStateProvider, (prev, next) {
      if (prev.runtimeType != next.runtimeType) {
        notifyListeners();
      }
    });
  }
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
