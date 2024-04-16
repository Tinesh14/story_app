import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  final Future<SharedPreferences> sharedPreferences;

  PreferencesHelper({required this.sharedPreferences});

  static const bearerToken = 'BEARER_TOKEN';

  Future<String?> get bearerTokenValue async {
    final prefs = await sharedPreferences;
    return prefs.getString(bearerToken);
  }

  void setBearerToken(String value) async {
    final prefs = await sharedPreferences;
    prefs.setString(bearerToken, value);
  }

  Future<bool> deleteToken() async {
    final prefs = await sharedPreferences;
    return await prefs.remove(bearerToken);
  }
}
