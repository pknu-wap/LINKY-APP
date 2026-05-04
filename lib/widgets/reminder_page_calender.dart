import 'package:flutter/material.dart';
import 'package:std/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:std/pages/calender_page.dart';

class CalenderWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final Function(DateTime focusedDay) onPageChanged;
  final List<Event> Function(DateTime day) eventLoader;

  const CalenderWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      firstDay: DateTime.utc(2000),
      lastDay: DateTime.utc(2100),
      focusedDay: focusedDay,
      headerVisible: false, // 커스텀 헤더를 사용하므로 숨김
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      eventLoader: eventLoader,

      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isNotEmpty) {
            // 선택된 날이나 오늘 날짜와 겹치지 않을 때만 표시하고 싶다면 조건 추가 가능
            // 여기서는 이벤트가 있으면 연한 빨간색 배경을 깔아줍니다.
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                // 원하는 연한 빨간색 (예: AppColors.mainPink 사용)
                color: AppColors.mainPink.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
            );
          }
          return null;
        },

        // 선택된 날짜 커스텀 스타일
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.calendarBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(color: AppColors.black),
              ),
            ),
          );
        },
        // 오늘 날짜 커스텀 스타일
        todayBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.mainGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
