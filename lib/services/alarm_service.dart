import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:std/main.dart';

class AlarmService {
  // kEvents 데이터를 받아서 모든 미래 일정을 예약하는 함수
  static Future<void> syncEventsWithAlarms(
    Map<DateTime, List<dynamic>> events,
  ) async {
    if (!(await Permission.notification.isGranted)) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    int baseId = 0; // 고유 ID를 위한 기반 변수

    for (var entry in events.entries) {
      DateTime date = entry.key;
      for (var event in entry.value) {
        // 정시(정각) 시간 계산
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          event.hour,
          event.minute,
        );

        // 30분 전 시간 계산
        final earlyTime = scheduledTime.subtract(const Duration(minutes: 30));

        // 1. [30분 전 알람] 예약 (ID: baseId * 2)
        if (earlyTime.isAfter(DateTime.now())) {
          await AndroidAlarmManager.oneShotAt(
            earlyTime,
            baseId * 2, // 30분 전 알람용 고유 ID
            alarmCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
          );
          print("30분 전 알람 예약: ${event.title} at $earlyTime");
        }

        // 2. [정시 알람] 예약 (ID: baseId * 2 + 1)
        if (scheduledTime.isAfter(DateTime.now())) {
          await AndroidAlarmManager.oneShotAt(
            scheduledTime,
            baseId * 2 + 1, // 정시 알람용 고유 ID
            alarmCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
          );
          print("정시 알람 예약: ${event.title} at $scheduledTime");
        }

        baseId++; // 다음 이벤트를 위해 ID 증가
      }
    }
  }
}
