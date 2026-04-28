import 'package:flutter/material.dart';
import 'package:std/widgets/calender_widget.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime(2026, 4, 1);
  DateTime? _selectedDay;
  String _getMonthName(int month) {
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void showEditConfirmDialog1(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.only(top: 30, bottom: 20),
        contentPadding: EdgeInsets.zero,
        title: const Text(
          '해당 링크를 수정하시겠어요?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '아니오',
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                      EditSheet1(context); // 바텀시트 열기
                    },
                    child: const Text(
                      '수정',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void EditSheet1(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F4F7), // 이미지 3의 배경색 느낌
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            buildEditField1('제목 수정', Icons.cancel),
            buildEditField1('URL 수정', Icons.cancel),
            const SizedBox(height: 20),
            buildEditField1('날짜 수정', Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  Widget buildEditField1(String hint, IconData suffixIcon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: Icon(suffixIcon, color: Colors.grey[400], size: 20),
        ),
      ),
    );
  }

  Widget today_reminder(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
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
            child: GestureDetector(
              onTap: () {
                print("$title 클릭됨!"); // 여기에 상세 페이지 이동 등 로직 추가
              },
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
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              if (value == '수정') {
                showEditConfirmDialog1(context);
              } else if (value == '삭제') {
                // 삭제 로직
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '수정',
                child: Row(
                  children: [
                    Icon(Icons.chevron_right, size: 18),
                    SizedBox(width: 8),
                    Text('수정'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: '삭제',
                child: Row(
                  children: [
                    Icon(Icons.chevron_right, size: 18),
                    SizedBox(width: 8),
                    Text('삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 30),
                child: Column(
                  children: [
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

                    /// 🔹 상단 헤더
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 년도 + 월 텍스트
                          Text(
                            "${_focusedDay.year}",
                            style: TextStyle(fontSize: 30, color: Colors.black),
                          ),
                          Text(
                            _getMonthName(_focusedDay.month).toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          ///컨트롤 (이전 / 월 / 년 / 다음)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// ◀ 이전 달
                              IconButton(
                                icon: Icon(Icons.chevron_left),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month - 1,
                                    );
                                  });
                                },
                              ),

                              /// 월 선택
                              Container(
                                width: 80,
                                height: 40,
                                padding: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ), // 테두리
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // 라운드
                                  color: Colors.grey[100],
                                ),
                                child: DropdownButton<int>(
                                  value: _focusedDay.month,
                                  underline: SizedBox(), // 기본 밑줄 제거
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  items: List.generate(12, (index) {
                                    return DropdownMenuItem(
                                      value: index + 1,
                                      child: Text("${index + 1}월"),
                                    );
                                  }),
                                  onChanged: (month) {
                                    setState(() {
                                      _focusedDay = DateTime(
                                        _focusedDay.year,
                                        month!,
                                      );
                                    });
                                  },
                                ),
                              ),

                              /// 연도 선택
                              Container(
                                padding: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ), // 테두리
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // 라운드
                                  color: Colors.grey[100],
                                ),
                                child: DropdownButton<int>(
                                  value: _focusedDay.year,
                                  underline: SizedBox(),
                                  items: List.generate(21, (index) {
                                    //21 변경하여 년도 범위 조정 가능
                                    int year = 2015 + index; // 시작 년도 2015
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text("$year"),
                                    );
                                  }),
                                  onChanged: (year) {
                                    setState(() {
                                      _focusedDay = DateTime(
                                        year!,
                                        _focusedDay.month,
                                      );
                                    });
                                  },
                                ),
                              ),

                              /// ▶ 다음 달
                              IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month + 1,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),

                    /// 🔹 캘린더
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
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),

                    SizedBox(height: 10),

                    /// 🔹 TODAY 영역
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            "TODAY",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    Expanded(
                      child: ValueListenableBuilder<List<Event>>(
                        valueListenable: _selectedEvents,
                        builder: (context, events, _) {
                          if (events.isEmpty) {
                            return const Center(
                              child: Text(
                                "등록된 일정이 없습니다.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return today_reminder(
                                context,
                                events[index].title,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 30,
              color: const Color(0xFF3FD966), // 이미지와 유사한 초록색
              child: Center(
                child: Container(
                  width: 4,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}

class Event {
  final String title;
  final int hour; // 0 ~ 23시를 나타내는 정보 추가

  const Event(this.title, {this.hour = 9}); // 기본값을 9시로 설정
}

// 데이터 예시 (시간 정보 포함)
final kEvents = {
  DateTime.utc(2026, 4, 23): [
    Event("플러터 공부하기", hour: 10),
    Event("팀 프로젝트 미팅", hour: 14),
  ],
  DateTime.utc(2026, 4, 24): [Event("운동하기", hour: 7)],
};
