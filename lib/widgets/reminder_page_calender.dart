import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:std/pages/calender_page.dart';

class CalenderWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final Function(DateTime focusedDay) onPageChanged;
  final List<Event> Function(DateTime day) eventLoader;

  const CalenderWidget({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
  }) : super(key: key);

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

      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Color(0xFF3FD966),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),

      calendarBuilders: CalendarBuilders(
        // 선택된 날짜 커스텀 스타일
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        },
        // 오늘 날짜 커스텀 스타일
        todayBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3FD966),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
