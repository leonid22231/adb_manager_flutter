import 'package:shared_preferences/shared_preferences.dart';

class ToolsStorage {
  SharedPreferences? pref;

  Future<void> init() async {
    pref ??= await SharedPreferences.getInstance();
  }

  bool isInit() => pref != null;

  void putString(String key, String s) {
    if (!isInit()) {
      return;
    }
    pref!.setString(key, s);
  }

  String getString(String key) {
    if (!isInit()) {
      return '';
    }
    return getStringNullable(key) ?? '';
  }

  String? getStringNullable(String key) {
    if (!isInit()) {
      return null;
    }
    String? s = pref!.getString(key);
    return s;
  }

  void remove(String key) {
    if (!isInit()) {
      return;
    }
    pref!.remove(key);
  }

  void putBool(String key, bool v) {
    if (!isInit()) {
      return;
    }
    pref!.setBool(key, v);
  }

  bool getBool(String key) {
    if (!isInit()) {
      return false;
    }
    bool v = pref!.getBool(key) ?? false;
    return v;
  }

  bool? getBoolNullable(String key) {
    if (!isInit()) {
      return null;
    }
    bool? v = pref!.getBool(key);
    return v;
  }

  void putStringList(String key, List<String> s) {
    if (!isInit()) {
      return;
    }
    pref!.setStringList(key, s);
  }

  List<String> getStringList(String key) {
    if (!isInit()) {
      return [];
    }
    List<String> s = pref!.getStringList(key) ?? [];
    return s;
  }

  void clear() {
    if (!isInit()) {
      return;
    }
    pref!.clear();
  }
}
