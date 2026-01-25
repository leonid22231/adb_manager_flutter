import 'package:adb_manager/utils/json_serializable_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_server_message.g.dart';

enum ServerMessageType { appstart }

@JsonSerializable()
class ServerMessage extends JsonSerializableModel {
  ServerMessageType type;
  String message;

  ServerMessage({required this.type, this.message = ''});
  
  factory ServerMessage.fromJson(Map<String, dynamic> json) =>
      _$ServerMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ServerMessageToJson(this);
}
