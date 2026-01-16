import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/utils/extensions.dart';
import 'package:adb_manager/views/widgets/widget_button.dart';
import 'package:adb_manager/views/widgets/widget_simple_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    ServiceDevice.instance.connectDevice(device);
  }

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
                    WidgetSimpleText(
                      text: DateFormat(
                        'Последнее обновление: dd-MM-yy HH:mm',
                      ).format(DateTime.now()),
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
                      '${device.deviceIp}${device.isEmulator() ? '' : ':${device.devicePort}'}',
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
                      _buildStatusChip(
                        'NETWORK',
                        device.deviceStatus == DeviceStatus.online,
                        Colors.green,
                      ),
                    ],
                    Spacer(),
                    if (device.connectStatus == ConnectStatus.disconnect) ...[
                      WidgetButton(
                        title: 'Connect',
                        onTap: onConnectDevice,
                        color: Colors.greenAccent,
                      ),
                    ],
                  ],
                ),
              ],
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
            color: (isOnline ? Colors.green : Colors.grey).withOpacity(0.4),
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
