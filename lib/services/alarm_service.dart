import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:std/main.dart';

class AlarmService {
  // kEvents 데이터를 받아서 모든 미래 일정을 예약하는 함수
  static Future<void> syncEventsWithAlarms(
    Map<DateTime, List<dynamic>> events,
  ) async {
    await Permission.notification.request();

    // 2. 정확한 알람 권한 요청 (Android 12+ 필수)
    // 이 권한이 없으면 exact: true 옵션 사용 시 에러가 납니다.
    var status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      // 권한 요청 페이지로 보내거나 요청을 시도합니다.
      await Permission.scheduleExactAlarm.request();
    }

    int alarmId = 0; // 고유 ID 생성을 위한 변수

    for (var entry in events.entries) {
      DateTime date = entry.key;
      List<dynamic> eventList = entry.value;

      for (var event in eventList) {
        // 날짜(date)와 이벤트의 시간/분을 합침
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          event.hour,
          event.minute,
        );

        // 현재보다 미래인 일정만 알람 등록
        if (scheduledTime.isAfter(DateTime.now())) {
          await AndroidAlarmManager.oneShotAt(
            scheduledTime,
            alarmId,
            alarmCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
          );
          print("자동 알람 예약: ${event.title} at $scheduledTime (ID: $alarmId)");
        }
        alarmId++; // 각 이벤트마다 고유 ID 부여
      }
    }
  }
}
