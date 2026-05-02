import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';
import 'package:std/widgets/puablic_dropdown_menu.dart';
import 'package:std/widgets/reminder_page_calender.dart';
import 'package:std/widgets/public_popup_menu_button.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int startYear = 2026;
  int endYear = 2099;
  List<String> months = [
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineGrey, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Widget today_reminder(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mainBackGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineGrey, width: 1), // 외곽선 추가
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.mainGreen,
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
                  color: AppColors.black,
                ),
              ],
            ),
          ),
          PopupButton(
            titleValue: '',
            urlValue: '',
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
      backgroundColor: AppColors.white,
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
                            color: AppColors.mainPink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.black,
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
                        color: AppColors.black,
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
                        Container(
                          width: 87,
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineGrey),
                          ),
                          child: DropdownWidget(
                            itemsList: months,
                            onCategorySelected: (value) {
                              setState(
                                () => _focusedDay = DateTime(
                                  _focusedDay.year,
                                  months.indexOf(value) + 1,
                                ),
                              );
                            },
                            menuWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  months[_focusedDay.month - 1],
                                  style: GoogleFonts.inter(fontSize: 16),
                                ),
                                const Icon(Icons.arrow_drop_down_outlined),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 87,
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineGrey),
                          ),
                          child: DropdownWidget(
                            itemsList: List.generate(
                              endYear - startYear + 1,
                              (index) => (startYear + index).toString(),
                            ),
                            onCategorySelected: (value) {
                              setState(
                                () => _focusedDay = DateTime(
                                  int.parse(value),
                                  _focusedDay.month,
                                ),
                              );
                            },
                            menuWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _focusedDay.year.toString(),
                                  style: GoogleFonts.inter(fontSize: 16),
                                ),
                                const Icon(Icons.arrow_drop_down_outlined),
                              ],
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
                                  color: AppColors.outlineGrey,
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
              color: AppColors.mainGreen,
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
                  color: AppColors.white.withValues(alpha: 0.8),
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
  final int minute;
  const Event(this.title, {this.hour = 9, this.minute = 0});
}

final Map<DateTime, List<Event>> kEvents =
    {}; // -> 알림 30분 전에 한번 울리고 정시간에 한번 더 울림
//데이터 하루 지나면 삭제 -> 만료시 색깔 변경
//년도 2099년
