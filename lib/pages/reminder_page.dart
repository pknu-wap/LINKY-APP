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
          // 2. 메인 컨텐츠 영역
          Expanded(
            child: SafeArea(
              child: Container(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 헤더: 아이콘 + 타이틀
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppBarDesign(
                        appbarText: 'Reminder',
                        appbarIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. 시간별 타임라인 (Vertical Scroll)
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

  // 타임라인 리스트
  // Widget Timeline() {
  //   final appState = context.watch<AppState>();
  //   final selectedDate = DateTime(
  //     DateTime.now().year,
  //     selectedMonth,
  //     selectedDay + 1,
  //   );
  //   print(selectedDate);
  //   // 2. 해당 날짜에 저장된 이벤트 리스트 가져오기
  //   final List<Event> dayEvents = appState.getEventsForDay(selectedDate);

  //   print(dayEvents.length);

  //   return ListView.builder(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     itemCount: 24, // 0시부터 23시까지
  //     itemBuilder: (context, index) {
  //       // 3. 현재 index(시간)와 일치하는 이벤트가 있는지 필터링
  //       final hourEvents = dayEvents.where((e) => e.hour == index).toList();

  //       // 시간 표시용 텍스트 (0시 -> 12am, 13시 -> 1pm 등)
  //       int displayHour = index == 0 || index == 12 ? 12 : index % 12;
  //       String amPm = index < 12 ? 'am' : 'pm';
  //       String timeStr = '$displayHour$amPm';

  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 15),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SizedBox(
  //               width: 50,
  //               child: Text(
  //                 timeStr,
  //                 style: GoogleFonts.inter(
  //                   color: AppColors.textGrey,
  //                   fontSize: 12,
  //                   decoration: TextDecoration.none,
  //                 ),
  //               ),
  //             ),
  //             // 4. 핵심 로직: 일정이 있으면 위젯을 보여주고, 없으면 투명한 빈 칸을 보여줌
  //             Expanded(
  //               child: hourEvents.isNotEmpty
  //                   ? RemindertaskWidget(
  //                       backgroundColor: AppColors.mainGreen,
  //                       // 여기서는 첫 번째 이벤트의 제목을 전달하는 식으로 커스텀 가능
  //                       contentID:
  //                           hourEvents.first.contentID, // 고유 id 가져오는 로직 추가 필요
  //                       eventDate: selectedDate,
  //                     )
  //                   : const SizedBox(height: 40), // 일정이 없을 때의 높이 확보
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

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
    // 이제 빌드 메서드 최상단에서 watch하는 것이 안전합니다.
    final appState = context.watch<AppState>();

    final selectedDate = DateTime(
      DateTime.now().year,
      selectedMonth,
      selectedDay, // 필요에 따라 유지
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
