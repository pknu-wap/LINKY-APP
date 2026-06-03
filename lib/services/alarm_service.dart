import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:std/main.dart';

class AlarmService {
  static int earlyAlarmId(int contentID) => contentID * 2;
  static int exactAlarmId(int contentID) => contentID * 2 + 1;

  static Future<void> requestPermissions() async {
    if (!(await Permission.notification.isGranted)) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  static Future<void> scheduleEventAlarm({
    required int contentID,
    required String title,
    required DateTime scheduledTime,
  }) async {
    await requestPermissions();

    final now = DateTime.now();
    final earlyTime = scheduledTime.subtract(const Duration(minutes: 30));

    await cancelEventAlarm(contentID);

    if (earlyTime.isAfter(now)) {
      await AndroidAlarmManager.oneShotAt(
        earlyTime,
        earlyAlarmId(contentID),
        alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }

    if (scheduledTime.isAfter(now)) {
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        exactAlarmId(contentID),
        alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }
  }

  static Future<void> cancelEventAlarm(int contentID) async {
    try {
      final earlyCanceled = await AndroidAlarmManager.cancel(
        earlyAlarmId(contentID),
      );
      final exactCanceled = await AndroidAlarmManager.cancel(
        exactAlarmId(contentID),
      );

      if (earlyCanceled != true && exactCanceled != true) {
        debugPrint(
          'Alarm cancellation may have failed for contentID=$contentID: '
          'early=$earlyCanceled exact=$exactCanceled',
        );
      }
    } catch (e) {
      debugPrint('알람 취소 에러: $e');
    }
  }

  static Future<void> syncEventsWithAlarms(
    Map<DateTime, List<dynamic>> events,
  ) async {
    await requestPermissions();

    for (final entry in events.entries) {
      final date = entry.key;

      for (final event in entry.value) {
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          event.hour,
          event.minute,
        );

        await scheduleEventAlarm(
          contentID: event.contentID,
          title: event.title,
          scheduledTime: scheduledTime,
        );
      }
    }
  }
}
