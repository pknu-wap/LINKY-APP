import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_appbar.dart';
import 'package:std/widgets/reminder_page_remindertask.dart';

class ReminderScreen extends StatefulWidget {
  final DateTime selectedDate;
  const ReminderScreen({super.key, required this.selectedDate});

  @override
  State<ReminderScreen> createState() => Reminder();
}

class Reminder extends State<ReminderScreen> {
  int selectedMonth = 0;
  int selectedDay = 0;
  int day_count = 0;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final selectedDate = widget.selectedDate;
    selectedMonth = selectedDate.month;
    selectedDay = selectedDate.day;
    day_count = getLastDayOfMonth(selectedDate.year, selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              child: Container(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppBarDesign(
                        appbarText: 'Reminder',
                        appbarIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: TimelineWidget(
                        selectedMonth: selectedMonth,
                        selectedDay: selectedDay,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int getLastDayOfMonth(int year, int month) {
    DateTime lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }
}

class TimelineWidget extends StatelessWidget {
  final int selectedMonth;
  final int selectedDay;

  const TimelineWidget({
    super.key,
    required this.selectedMonth,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();

    final selectedDate = DateTime(
      DateTime.now().year,
      selectedMonth,
      selectedDay,
    );

    final List<Event> dayEvents = appState.getEventsForDay(selectedDate);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 24,
      itemBuilder: (context, index) {
        final hourEvents = dayEvents.where((e) => e.hour == index).toList();

        int displayHour = index == 0 || index == 12 ? 12 : index % 12;
        String amPm = index < 12 ? 'am' : 'pm';
        String timeStr = '$displayHour$amPm';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Expanded(
                child: hourEvents.isNotEmpty
                    ? RemindertaskWidget(
                        backgroundColor: AppColors.mainGreen,
                        contentID: hourEvents.first.contentID,
                        eventDate: selectedDate,
                      )
                    : const SizedBox(height: 40),
              ),
            ],
          ),
        );
      },
    );
  }
}
