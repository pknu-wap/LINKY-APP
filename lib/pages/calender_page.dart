import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/reminder_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_appbar.dart';
import 'package:std/widgets/public_dropdown_menu.dart';
import 'package:std/widgets/reminder_page_calender.dart';
import 'package:std/widgets/public_popup_menu_button.dart';
import 'package:table_calendar/table_calendar.dart';

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

  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    _appState = Provider.of<AppState>(context, listen: false);

    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _appState.addListener(_handleAppStateChange);
  }

  void _handleAppStateChange() {
    if (!mounted) return; // 위젯이 사라졌으면 무시

    if (_selectedDay != null) {
      setState(() {
        final newEvents = _appState.getEventsForDay(_selectedDay!);

        _selectedEvents.value = newEvents;
      });
    }
  }

  void _updatePage(int contentID) {
    if (_selectedDay == null) return;

    context.read<AppState>().removeEvent(_selectedDay!, contentID);

    // 변경된 일정을 화면(ValueNotifier)에 갱신
    _selectedEvents.value = context.read<AppState>().getEventsForDay(
      _selectedDay!,
    );
  }

  @override
  void dispose() {
    _appState.removeListener(_handleAppStateChange);
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
    final dateOnly = DateTime(day.year, day.month, day.day);
    return kEvents[dateOnly] ?? [];
  }

  Widget today_reminder(BuildContext context, Event event, int index) {
    return Builder(
      builder: (innerContext) {
        final currentContent = innerContext.select<AppState, ContentItem?>(
          (state) => state.contentById(event.contentID),
        );

        final displayTitle = currentContent?.title ?? event.title;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mainBackGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineGrey,
              width: 1,
            ), // 외곽선 추가
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
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.black,
                        ),
                        SizedBox(width: 7),
                        Text(
                          '${event.hour.toString().padLeft(2, '0')}:${event.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupButton(
                contentID: event.contentID,
                onActionDone: () => _updatePage(event.contentID),
                context: context,
              ),
            ],
          ),
        );
      },
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
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: CustomScrollView(
                  slivers: [
                    // ✅ 헤더 ~ TODAY 텍스트까지
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          AppBarDesign(
                            appbarText: 'Reminder',
                            appbarIcon: Icons.calendar_today_outlined,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "${_focusedDay.year}",
                            style: const TextStyle(
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
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.outlineGrey,
                                  ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        months[_focusedDay.month - 1],
                                        style: GoogleFonts.inter(fontSize: 16),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 87,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.outlineGrey,
                                  ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _focusedDay.year.toString(),
                                        style: GoogleFonts.inter(fontSize: 16),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down_outlined,
                                      ),
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
                          const SizedBox(height: 10),
                          CalenderWidget(
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            eventLoader: _getEventsForDay,
                            onDaySelected: (selectedDay, focusedDay) {
                              if (isSameDay(_selectedDay, selectedDay)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReminderScreen(
                                      selectedDate: selectedDay,
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                  _selectedEvents.value = _getEventsForDay(
                                    selectedDay,
                                  );
                                });
                              }
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
                        ],
                      ),
                    ),

                    // ✅ 일정 리스트 (Expanded 없이 SliverList로)
                    ValueListenableBuilder<List<Event>>(
                      valueListenable: _selectedEvents,
                      builder: (context, events, _) {
                        if (events.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                "등록된 일정이 없습니다.",
                                style: TextStyle(
                                  color: AppColors.outlineGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => today_reminder(
                              context,
                              events[index],
                              index,
                            ),
                            childCount: events.length,
                          ),
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
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
  final int contentID;
  final String title;
  final int hour;
  final int minute;
  const Event(this.contentID, this.title, {this.hour = 9, this.minute = 0});
}

final Map<DateTime, List<Event>> kEvents = {
};
