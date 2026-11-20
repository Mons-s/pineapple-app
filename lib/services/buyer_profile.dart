import 'package:shared_preferences/shared_preferences.dart';

class BuyerProfile {
  static const _keyName = 'buyer_name';
  static const _keyPhone = 'buyer_phone';

  static Future<({String name, String phone})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    final phone = prefs.getString(_keyPhone);
    if (name == null || name.isEmpty || phone == null || phone.isEmpty) return null;
    return (name: name, phone: phone);
  }

  static Future<void> save(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name.trim());
    await prefs.setString(_keyPhone, phone.trim());
  }
}
