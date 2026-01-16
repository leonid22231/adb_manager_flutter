// ignore_for_file: hash_and_equals

import 'dart:convert';

abstract class JsonSerializableModel {
  Map<String, dynamic> toJson();

  String toJsonString() => jsonEncode(toJson());

  bool equals(JsonSerializableModel o) => toJsonString() == o.toJsonString();

  @override
  bool operator ==(Object other) =>
      other is JsonSerializableModel && equals(other);

  @override
  String toString() {
    return '$runtimeType: ${toJsonString()}';
  }
}
