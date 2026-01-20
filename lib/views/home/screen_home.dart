import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/models/model_device_ports_info.dart';
import 'package:adb_manager/services/service_adb.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/services/service_window_manager.dart';
import 'package:adb_manager/utils/extensions.dart';
import 'package:adb_manager/views/utils/screen_widgets.dart';
import 'package:adb_manager/views/widgets/widget_device.dart';
import 'package:adb_manager/views/widgets/widget_icon_button.dart';
import 'package:adb_manager/views/widgets/widget_refresh_indicator.dart';
import 'package:adb_manager/views/widgets/widget_simple_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<StatefulWidget> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State with SingleTickerProviderStateMixin {
  late AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    di<ServiceWindowManager>().hideIfAutoStart();
    _ticker = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    di<ServiceDevice>().init();
    di<ServiceDevice>().addListener(update);
    di<ServiceAdb>().addListener(update);
    startListening();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void update() {
    setStateIfMounted();
  }

  void startListening() async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 41174);
    log('Сервер слушает на порту 41174...');

    await for (final client in server) {
      handleClient(client);
    }
  }

  void handleClient(Socket client) async {
    log('Соединение от ${client.remoteAddress.address}:${client.remotePort}');

    List<int> bytes = [];

    try {
      // Читаем все байты в память
      await for (final chunk in client) {
        bytes.addAll(chunk);

        // Декодируем только когда есть данные
        final message = utf8.decode(bytes, allowMalformed: true);
        log(message);

        DevicePortsInfo portsInfo = DevicePortsInfo.fromJson(
          jsonDecode(message),
        );

        processPorts(portsInfo.ports, client.remoteAddress.address);
      }
    } catch (e) {
      log('Ошибка: $e');
    } finally {
      client.close();
    }
  }

  void processPorts(List<String> ports, String sourceIp) {
    log('От $sourceIp получены порты: $ports ${DateTime.now()}');
    di<ServiceDevice>().updateDevice(sourceIp, ports);
  }

  void addDevice() async {
    Device? newDevice = await showAddDeviceDialog();
    if (newDevice == null) {
      return;
    }

    bool isValid = _isValidIPv4(newDevice.deviceIp!);
    if (!isValid) {
      showSimpleMessage('Неправильный IP адрес');
      return;
    }

    di<ServiceDevice>().addDevice(newDevice);
  }

  void showSimpleMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  void syncDevicesWithAdb() {
    di<ServiceAdb>().syncAdbDevices();
  }

  void updateAdbStatus() {
    di<ServiceAdb>().syncAdbStatus();
  }

  void updateDeviceStatus() {
    di<ServiceDevice>().syncDevices();
  }

  bool _isValidIPv4(String ip) {
    if (ip.isEmpty) return false;

    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (String part in parts) {
      if (part.isEmpty) return false;
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
  }

  Future<Device?> showAddDeviceDialog() async {
    final ipController = TextEditingController();
    final nameController = TextEditingController();

    return showDialog<Device>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        child: Container(
          width: 380,
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.setOpacity(0.12),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.blue,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Добавить устройство',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),
              _buildTextField(
                controller: ipController,
                label: 'IP адрес',
                hint: '192.168.1.100',
                icon: Icons.network_wifi,
                isIp: true,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: nameController,
                label: 'Название',
                hint: 'Samsung Galaxy S23',
                icon: Icons.phone_android,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      text: 'Отмена',
                      color: Colors.grey.shade400,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildButton(
                      text: 'Добавить',
                      color: Colors.blue.shade500,
                      onTap: () {
                        final ip = ipController.text.trim();
                        final name = nameController.text.trim().isEmpty
                            ? ip
                            : nameController.text.trim();

                        Navigator.pop(
                          context,
                          Device(deviceIp: ip, name: name),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    bool isIp = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.setOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: isIp
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;

                      final parts = text.split('.');
                      for (String part in parts) {
                        if (part.isNotEmpty &&
                            (int.tryParse(part) == null || part.length > 3)) {
                          return oldValue;
                        }
                      }

                      if (parts.length > 4) return oldValue;

                      return newValue;
                    }),
                  ]
                : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(icon, color: Colors.grey.shade500, size: 22),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.setOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  //
  //Widget
  //

  @override
  Widget build(BuildContext context) {
    return ScreenWidgets.overlay(
      context,
      child: Stack(
        children: [
          Scaffold(body: buildDevicePart()),
          if (di<ServiceDevice>().syncRunning)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10, left: 10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: WidgetRefreshIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDevicePart() {
    if (!di<ServiceAdb>().adbAvailable) {
      return Container(
        decoration: BoxDecoration(color: Colors.black45),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WidgetSimpleText(text: 'ADB is not available'),
              SizedBox(width: 10),
              WidgetIconButton(
                icon: Icons.refresh,
                onTap: syncDevicesWithAdb,
                description: 'Проверить доступность ADB',
                isDark: true,
              ),
            ],
          ),
        ),
      );
    }
    if (di<ServiceDevice>().isEmpty()) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WidgetSimpleText(text: 'Devices not found'),
            SizedBox(width: 10),
            WidgetIconButton(
              icon: Icons.add,
              onTap: addDevice,
              description: 'Нажмите для добавления устройства',
            ),
            SizedBox(width: 10),
            WidgetSimpleText(text: 'or'),
            SizedBox(width: 10),
            WidgetIconButton(
              icon: Icons.sync_sharp,
              onTap: syncDevicesWithAdb,
              description: 'Нажмите для синхронизации устройств ADB',
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              WidgetIconButton(
                icon: Icons.sync,
                onTap: updateDeviceStatus,
                size: 50,
                isDark: true,
                description: 'Нажмите для обновления статуса устройств',
              ),
              SizedBox(width: 10),
              WidgetIconButton(
                icon: Icons.add,
                onTap: addDevice,
                size: 50,
                isDark: true,
                description: 'Нажмите для добавления устройства',
              ),
              Spacer(),
              AnimatedBuilder(
                animation: _ticker,
                builder: (context, child) {
                  final lastUpdate = di<ServiceDevice>().lastUpdate;
                  final text = lastUpdate != null
                      ? 'Обновлено: ${lastUpdate.timeAgo}'
                      : 'Нет обновлений';

                  return WidgetSimpleText(text: text);
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) =>
                WidgetDevice(device: di<ServiceDevice>().deviceByIndex(index)),
            separatorBuilder: (context, index) => SizedBox(height: 5),
            itemCount: di<ServiceDevice>().count(),
          ),
        ],
      ),
    );
  }
}

class StringCompleter {
  final Completer<String> _completer = Completer<String>();
  Future<String> get future => _completer.future;
  void complete(String value) => _completer.complete(value);
}
