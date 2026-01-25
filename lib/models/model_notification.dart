import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/utils/json_serializable_model.dart';
import 'package:adb_manager/views/utils/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_notification.g.dart';

@JsonSerializable()
class Notification extends JsonSerializableModel {
  int? id;
  String? title;
  String? body;
  String? subtitle;
  String? payload;
  Notification({this.id, this.title, this.body, this.payload, this.subtitle});

  void show({NotificationDetails? details, bool showID = false}) {
    id ??= App.di<ServiceNotifications>().newNotificationId();
    String? tempTitle = title;
    if (showID) {
      tempTitle = '$title {id: [$id]}';
    }
    NotificationDetails notificationDetails =
        (details ?? ServiceNotifications.defaultDetails);

    App.di<ServiceNotifications>().pluginInstance.show(
      id!,
      tempTitle,
      body,
      notificationDetails,
      payload: payload,
    );

    App.di<ServiceNotifications>().saveNotification(this);
  }

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
