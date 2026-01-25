import 'dart:convert';

class JsonUtils {
  static final List<dynamic Function(Map<String, dynamic>)> factories = [];

  static void register<T>(T Function(Map<String, dynamic>) constructor) {
    factories.add(constructor);
  }

  static dynamic classFromJson(String json) {
    final jsonMap = jsonDecode(json) as Map<String, dynamic>;
    for (dynamic Function(Map<String, dynamic>) fnc in factories) {
      try {
        dynamic value = fnc.call(jsonMap);
        return value;
      } catch (e) {
        continue;
      }
    }

    return null;
  }
}
