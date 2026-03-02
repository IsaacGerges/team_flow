import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  final SharedPreferences sharedPreferences;

  CacheHelper({required this.sharedPreferences});

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);
    if (value is double) return await sharedPreferences.setDouble(key, value);
    return false;
  }

  dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}

class CacheKeys {
  static const String userId = 'USER_ID';
}
