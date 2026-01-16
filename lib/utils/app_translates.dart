enum AppTranslates {
  appName('ADB Manager'),
  //Notification TEST
  notificationTestTitle('Test title'),
  notificationTestBody('Test body'),
  //Notification device online
  notificationDeviceOnlineTitle('Устройство появилось в сети'),
  notificationDeviceOnlineBody('Устройство "{name}" появилось в сети'),
  //Notification device offline
  notificationDeviceOfflineTitle('Устройство больше не в сети'),
  notificationDeviceOfflineBody('Устройство "{name}" больше не в сети'),
  //Notification device unstable
  notificationDeviceUnstableTitle('Соединение с устрйством нестабильно'),
  notificationDeviceUnstableBody(
    'Соединение с устройством "{name}" нестабильно',
  ),
  //Notification device adb not connect
  notificationDeviceAdbNotConnectTitle('Не удалось подключить к устройству'),
  notificationDeviceAdbNotConnectBody(
    'Не удалось подключить к устройству по ADB.Возможно: ADB-отладка выключена на устройстве.Неверный IP-адрес или порт',
  );

  const AppTranslates(this.value);
  final String value;

  @override
  String toString() => value;

  String toStringValues(List<AppTranslatesValue> values) {
    String text = toString();
    for (AppTranslatesValue value in values) {
      text = _replaceString(text, value: value);
    }
    return text;
  }

  String _replaceString(String original, {required AppTranslatesValue value}) {
    return original.replaceFirst('{${value.name}}', value.value);
  }
}

class AppTranslatesValue {
  String name;
  String value;

  AppTranslatesValue({required this.name, required this.value});
}
