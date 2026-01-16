import 'package:shared_preferences/shared_preferences.dart';

class ToolsStorage {
  SharedPreferences? pref;

  Future<void> init() async {
    pref ??= await SharedPreferences.getInstance();
  }

  bool isInit() => pref != null;

  void putString(String key, String s) {
    pref!.setString(key, s);
  }

  String getString(String key) {
    return getStringNullable(key) ?? '';
  }

  String? getStringNullable(String key) {
    String? s = pref!.getString(key);
    return s;
  }

  void remove(String key) {
    pref!.remove(key);
  }

  void putBool(String key, bool v) {
    pref!.setBool(key, v);
  }

  bool getBool(String key) {
    bool v = pref!.getBool(key) ?? false;
    return v;
  }

  bool? getBoolNullable(String key) {
    bool? v = pref!.getBool(key);
    return v;
  }

  void putStringList(String key, List<String> s) {
    pref!.setStringList(key, s);
  }

  List<String> getStringList(String key) {
    List<String> s = pref!.getStringList(key) ?? [];
    return s;
  }

  void clear() {
    pref!.clear();
  }
}
