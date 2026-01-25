import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/services/proxies/service_device_proxy.dart';
import 'package:adb_manager/utils/extensions.dart';
import 'package:adb_manager/views/utils/app.dart';
import 'package:adb_manager/views/widgets/widget_button.dart';
import 'package:adb_manager/views/widgets/widget_simple_text.dart';
import 'package:flutter/material.dart';

class WidgetDevice extends StatefulWidget {
  final Device device;
  const WidgetDevice({required this.device, super.key});

  @override
  State<StatefulWidget> createState() => _WidgetDeviceState();
}

class _WidgetDeviceState extends State<WidgetDevice> {
  late Device device;
  @override
  void initState() {
    super.initState();
    device = widget.device;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    device = widget.device;
  }

  void onConnectDevice() {
    App.di<ServiceDeviceProxy>().connectDevice(device);
  }

  void onDisconnectDevice() {
    App.di<ServiceDeviceProxy>().disconnectDevice(device);
  }

  void onOptionsTap() {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      showOptionsPopup();
    });
  }

  showOptionsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Container(
            width: 380,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.setOpacity(0.4),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
              border: Border.all(
                color: Color(0xFF00d4ff).setOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF00d4ff).setOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Color(0xFF00d4ff),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Настройки',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white70, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 28),

                // Опции
                _buildOptionTile(
                  context,
                  icon: Icons.delete,
                  title: 'Удалить',
                  subtitle: 'Удалить устройство из списка',
                  color: Colors.redAccent,
                  onTap: () {
                    App.di<ServiceDeviceProxy>().removeDevice(device);
                    Navigator.of(context).pop();
                  },
                ),

                SizedBox(height: 24),

                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        'Отмена',
                        color: Colors.grey.shade800,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildButton(
                        'Сохранить',
                        gradient: LinearGradient(
                          colors: [Color(0xFF00d4ff), Color(0xFF0099cc)],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // Сохранить настройки
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.setOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.setOpacity(0.2), color.setOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.setOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    Color? color,
    Gradient? gradient,
    required VoidCallback onPressed,
  }) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient:
                gradient ??
                LinearGradient(colors: [color!, color.setOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (gradient?.colors.first ?? color!).setOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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
    return Container(
      width: 320,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              device.deviceStatus == DeviceStatus.online &&
                      device.connectStatus == ConnectStatus.connect ||
                  device.isEmulator() &&
                      device.connectStatus == ConnectStatus.connect
              ? [Colors.blue.shade50, Colors.white]
              : [Colors.grey.shade100, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.setOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: device.connectStatus == ConnectStatus.connect
              ? Colors.blue.shade200
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.setOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              device.deviceType == DeviceType.emulator
                  ? Icons.bug_report_outlined
                  : Icons.smartphone,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          // Основная информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    if (device.deviceAppInfo.appInstalled)
                      WidgetSimpleText(
                        text: 'App version: ${device.deviceAppInfo.appVersion}',
                      ),
                    SizedBox(width: 10),
                    _buildStatusDot(
                      device.isEmulator()
                          ? device.connectStatus == ConnectStatus.connect
                          : device.deviceStatus == DeviceStatus.online &&
                                device.connectStatus == ConnectStatus.connect,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      device.deviceType.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      device.getAddressMaybeNotPort(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip(
                      'ADB',
                      device.connectStatus == ConnectStatus.connect,
                      Colors.green,
                    ),
                    if (!device.isEmulator()) ...[
                      SizedBox(width: 8),
                      _buildNetworkStatusChip('NETWORK', device.deviceStatus),
                      SizedBox(width: 8),
                      _buildStatusChip(
                        'APP',
                        device.deviceAppInfo.appInstalled,
                        Colors.green,
                      ),
                    ],
                    Spacer(),
                    if (device.isConnectAvailable()) ...[
                      WidgetButton(
                        title: 'Connect',
                        onTap: onConnectDevice,
                        color: Colors.greenAccent,
                      ),
                    ] else if (device.isDisconnectAvailable())
                      WidgetButton(
                        title: 'Disconnect',
                        onTap: onDisconnectDevice,
                        color: Colors.redAccent,
                      ),
                    SizedBox(width: 12),
                    WidgetButton(
                      title: 'options',
                      onTap: showOptionsPopup,
                      color: Colors.lightBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusChip(String label, DeviceStatus status) {
    Color backgroundColor;
    Color borderColor;
    Color dotColor;
    Color textColor;

    switch (status) {
      case DeviceStatus.online:
        backgroundColor = Color(0xFF22c55e).setOpacity(0.15);
        borderColor = Color(0xFF22c55e).setOpacity(0.4);
        dotColor = Color(0xFF22c55e);
        textColor = Color(0xFF22c55e);
        break;

      case DeviceStatus.offline:
        backgroundColor = Color(0xFFef4444).setOpacity(0.15);
        borderColor = Color(0xFFef4444).setOpacity(0.4);
        dotColor = Color(0xFFef4444);
        textColor = Color(0xFFef4444);
        break;

      case DeviceStatus.unstable:
        backgroundColor = Color(0xFFeab308).setOpacity(0.15);
        borderColor = Color(0xFFeab308).setOpacity(0.4);
        dotColor = Color(0xFFeab308);
        textColor = Color(0xFFeab308);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: [
                BoxShadow(
                  color: dotColor.setOpacity(0.4),
                  blurRadius: 3,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool active, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.setOpacity(0.15) : Colors.redAccent.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color.setOpacity(0.3) : Colors.redAccent.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? color : Colors.redAccent.shade400,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? color : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(bool isOnline) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isOnline
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.grey.shade400, Colors.grey.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? Colors.green : Colors.grey).setOpacity(0.4),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget buildStatus(bool value) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: value ? Colors.green : Colors.red,
      ),
    );
  }
}
