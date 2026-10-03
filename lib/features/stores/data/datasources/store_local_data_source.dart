import 'package:shared_preferences/shared_preferences.dart';

abstract class StoreLocalDataSource {
  String? getSelectedStoreId();

  Future<void> saveSelectedStoreId(
    String storeId,
  );

  Future<void> clearSelectedStoreId();
}

class StoreLocalDataSourceImpl implements StoreLocalDataSource {
  static const String _selectedStoreIdKey = 'selected_store_id';

  final SharedPreferences sharedPreferences;

  StoreLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  String? getSelectedStoreId() {
    final value = sharedPreferences.get(
      _selectedStoreIdKey,
    );

    // Previous builds stored an int here.
    // Ignore that obsolete value rather than crashing
    // or treating it as a real backend UUID.
    if (value is! String) {
      return null;
    }

    final storeId = value.trim();

    return storeId.isEmpty ? null : storeId;
  }

  @override
  Future<void> saveSelectedStoreId(
    String storeId,
  ) async {
    await sharedPreferences.setString(
      _selectedStoreIdKey,
      storeId,
    );
  }

  @override
  Future<void> clearSelectedStoreId() async {
    await sharedPreferences.remove(
      _selectedStoreIdKey,
    );
  }
}
