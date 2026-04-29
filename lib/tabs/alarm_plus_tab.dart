import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:std/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:std/widgets/alarm_setup_widget.dart';

class ManagerPlusTab extends StatelessWidget {
  const ManagerPlusTab({super.key});

  Future<void> _handleSetAlarm(BuildContext context, DateTime scheduledTime) async {
    // 1. 알림 권한 체크 (Android 13+)
    if (await Permission.notification.request().isGranted) {
      // 2. 알람 예약
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        0, // 알람 ID
        alarmCallback, // main.dart에 정의된 최상위 함수
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알람이 $scheduledTime 에 예약되었습니다.')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림 권한이 필요합니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlarmSetupWidget(
      buttonText: 'Set Manager+ Alarm (Vibrate Only)',
      onSetAlarm: (scheduledTime) => _handleSetAlarm(context, scheduledTime),
    );
  }
}