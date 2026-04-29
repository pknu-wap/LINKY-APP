import 'package:flutter/material.dart';
import 'package:std/widgets/reminder_page_calender.dart';
import 'package:std/widgets/public_popup_menu_button.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime(2026, 4, 1);
  DateTime? _selectedDay;
  int startYear = 2015;
  int endYear = 2035;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  List<Event> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime.utc(day.year, day.month, day.day);
    return kEvents[dateOnly] ?? [];
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[400]!, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Widget today_reminder(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100], // 배경색을 조금 더 밝게 조정
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1), // 외곽선 추가
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF3FD966),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          PopupButton(
            onActionDone: () => print('삭제 버튼 클릭됨'),
            context: context,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // 1. Reminder 헤더 추가
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFBFF3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Reminder",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 연도 및 월 표시
                    Text(
                      "${_focusedDay.year}",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getMonthName(_focusedDay.month).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 연/월 선택 및 컨트롤러
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.chevron_left, size: 30),
                          onPressed: () => setState(() {
                            DateTime newDate = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                            );
                            if (newDate.year >= startYear) {
                              _focusedDay = newDate;
                            }
                          }),
                        ),
                        const SizedBox(width: 25),
                        _buildDropdownContainer(
                          child: DropdownButton<int>(
                            value: _focusedDay.month,
                            items: List.generate(12, (index) => index + 1)
                                .map(
                                  (month) => DropdownMenuItem(
                                    value: month,
                                    child: Text(_getMonthName(month)),
                                  ),
                                )
                                .toList(),
                            onChanged: (month) => setState(
                              () => _focusedDay = DateTime(
                                _focusedDay.year,
                                month!,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        _buildDropdownContainer(
                          child: DropdownButton<int>(
                            value: _focusedDay.year.clamp(startYear, endYear),
                            items:
                                List.generate(
                                      endYear - startYear + 1,
                                      (index) => startYear + index,
                                    )
                                    .map(
                                      (year) => DropdownMenuItem(
                                        value: year,
                                        child: Text(year.toString()),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (year) => setState(
                              () => _focusedDay = DateTime(
                                year!,
                                _focusedDay.month,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.chevron_right, size: 30),
                          onPressed: () => setState(() {
                            DateTime newDate = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                            );
                            if (newDate.year <= endYear) {
                              _focusedDay = newDate;
                            }
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CalenderWidget(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      eventLoader: _getEventsForDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedEvents.value = _getEventsForDay(selectedDay);
                        });
                      },
                      onPageChanged: (focusedDay) =>
                          setState(() => _focusedDay = focusedDay),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "TODAY",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ValueListenableBuilder<List<Event>>(
                        valueListenable: _selectedEvents,
                        builder: (context, events, _) {
                          if (events.isEmpty) {
                            return Center(
                              child: Text(
                                "등록된 일정이 없습니다.",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: events.length,
                            itemBuilder: (context, index) =>
                                today_reminder(context, events[index].title),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 2. 우측 초록색 바 (Sidebar)
          Container(
            width: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF3FD966),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final int hour;
  const Event(this.title, {this.hour = 9});
}

final kEvents = {
  DateTime.utc(2026, 4, 23): [
    Event("플러터 공부하기", hour: 10),
    Event("팀 프로젝트 미팅", hour: 14),
  ],
  DateTime.utc(2026, 4, 24): [Event("운동하기", hour: 7)],
};
