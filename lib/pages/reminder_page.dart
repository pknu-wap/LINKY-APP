import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/reminder_page_remindertask.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

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
    DateTime now = DateTime.now();
    selectedMonth = now.month - 1; // 월은 0부터 시작하므로
    selectedDay = now.day - 1; // 일도 0부터 시작
    day_count = getLastDayOfMonth(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //좌측 초록색 사이드바 (페이지 전환 영역)
          Container(
            width: 30,
            decoration: const BoxDecoration(
              color: AppColors.mainGreen,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
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

          // 2. 메인 컨텐츠 영역
          Expanded(
            child: Container(
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // 헤더: 아이콘 + 타이틀
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
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
                        const SizedBox(width: 12),
                        const Text(
                          'Reminder',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. 월 선택 (Horizontal Scroll)
                  _MonthScroll(),
                  const SizedBox(height: 20),

                  // 4. 일 선택 (Horizontal Scroll)
                  _DayScroll(),
                  const SizedBox(height: 20),

                  // 5. 시간별 타임라인 (Vertical Scroll)
                  Expanded(child: Timeline()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 월 선택 바 (클릭 시 색상 변경)
  Widget _MonthScroll() {
    return SizedBox(
      height: 40, // 가로 리스트의 경우 높이 지정 필수
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: months.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedMonth == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMonth = index;
                day_count = getLastDayOfMonth(DateTime.now().year, index + 1);
                if (selectedDay >= day_count) {
                  selectedDay = day_count - 1;
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // 선택되었을 때 회색, 아닐 때 흰색 배경
                color: isSelected ? AppColors.popupBackGrey : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.popupBackGrey),
              ),
              child: Text(
                months[index],
                style: TextStyle(
                  color: isSelected
                      ? AppColors.black
                      : AppColors.black.withValues(alpha: 0.541),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 일 선택 바 (클릭 시 색상 변경)
  Widget _DayScroll() {
    return SizedBox(
      height: 90, // 가로 리스트의 경우 높이 지정 필수
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: day_count,
        itemBuilder: (context, index) {
          bool isSelected = selectedDay == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = index;
              });
            },
            child: Container(
              width: 50,
              height: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                // 선택되었을 때 초록색, 아닐 때 흰색
                color: isSelected ? AppColors.darkGreen : AppColors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppColors.transparent
                      : AppColors.lightGrey,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.darkGreen.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 타임라인 리스트
  Widget Timeline() {
    final appState = context.watch<AppState>();
    // 1. 현재 선택된 '년, 월, 일'을 기준으로 DateTime 객체 생성
    // selectedMonth, selectedDay는 0부터 시작하므로 +1 해줍니다.
    final selectedDate = DateTime.utc(
      DateTime.now().year,
      selectedMonth + 1,
      selectedDay + 1,
    );

    // 2. 해당 날짜에 저장된 이벤트 리스트 가져오기
    final List<Event> dayEvents = appState.getEventsForDay(selectedDate);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 24, // 0시부터 23시까지
      itemBuilder: (context, index) {
        // 3. 현재 index(시간)와 일치하는 이벤트가 있는지 필터링
        final hourEvents = dayEvents.where((e) => e.hour == index).toList();

        // 시간 표시용 텍스트 (0시 -> 12am, 13시 -> 1pm 등)
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
                  ),
                ),
              ),
              // 4. 핵심 로직: 일정이 있으면 위젯을 보여주고, 없으면 투명한 빈 칸을 보여줌
              Expanded(
                child: hourEvents.isNotEmpty
                    ? RemindertaskWidget(
                        backgroundColor: AppColors.mainGreen,
                        // 여기서는 첫 번째 이벤트의 제목을 전달하는 식으로 커스텀 가능
                        contentID:
                            hourEvents.first.contentID, // 고유 id 가져오는 로직 추가 필요
                        eventDate: selectedDate,
                      )
                    : const SizedBox(height: 40), // 일정이 없을 때의 높이 확보
              ),
            ],
          ),
        );
      },
    );
  }

  int getLastDayOfMonth(int year, int month) {
    DateTime lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }
}
