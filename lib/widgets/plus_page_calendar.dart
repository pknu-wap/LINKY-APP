import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:std/constants.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChanged;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onChanged,
  });

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          showLinkyCalendarPicker(
            context,
            initialDate: selectedDate,
            onChanged: onChanged,
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.mainGreen,
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedDate == null
                  ? '만료일 선택'
                  : '만료일: ${_formatDate(selectedDate!)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.black,
              size: 29,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showLinkyCalendarPicker(
  BuildContext buttonContext, {
  required DateTime? initialDate,
  required ValueChanged<DateTime> onChanged,
}) async {
  final renderObject = buttonContext.findRenderObject();

  if (renderObject is! RenderBox) return;

  final buttonBox = renderObject;
  final buttonOffset = buttonBox.localToGlobal(Offset.zero);
  final screenSize = MediaQuery.of(buttonContext).size;

  final now = DateTime.now();

  final baseDate =
      initialDate ??
      DateTime(
        now.year,
        now.month,
        now.day,
        8,
        0,
      );

  final popupWidth = math.min(buttonBox.size.width, 320.0);
  final safePopupWidth = math.max(240.0, popupWidth);

  final left = (buttonOffset.dx + (buttonBox.size.width - safePopupWidth) / 2)
      .clamp(8.0, screenSize.width - safePopupWidth - 8.0)
      .toDouble();

  final top = (buttonOffset.dy + buttonBox.size.height - 10)
      .clamp(0.0, screenSize.height - 230)
      .toDouble();

  await showGeneralDialog<void>(
    context: buttonContext,
    barrierDismissible: true,
    barrierLabel: 'calendar',
    barrierColor: AppColors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: safePopupWidth,
              child: LinkyCalendarPicker(
                initialDate: baseDate,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class LinkyCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;

  const LinkyCalendarPicker({
    super.key,
    required this.initialDate,
    required this.onChanged,
  });

  @override
  State<LinkyCalendarPicker> createState() => _LinkyCalendarPickerState();
}

class _LinkyCalendarPickerState extends State<LinkyCalendarPicker> {
  static const List<String> months = [
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

  static const List<String> weekDays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  late DateTime selectedDate;
  late DateTime visibleMonth;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.initialDate;
    visibleMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );

    selectedTime = TimeOfDay(
      hour: widget.initialDate.hour,
      minute: widget.initialDate.minute,
    );
  }

  void notifyChanged() {
    widget.onChanged(
      DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );
  }

  void goPreviousMonth() {
    setState(() {
      visibleMonth = DateTime(
        visibleMonth.year,
        visibleMonth.month - 1,
      );
    });
  }

  void goNextMonth() {
    setState(() {
      visibleMonth = DateTime(
        visibleMonth.year,
        visibleMonth.month + 1,
      );
    });
  }

  int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> pickTime() async {
    int tempHour = selectedTime.hour;
    int tempMinute = selectedTime.minute;

    final hourController = FixedExtentScrollController(
      initialItem: tempHour,
    );

    final minuteController = FixedExtentScrollController(
      initialItem: tempMinute,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      builder: (context) {
        return Container(
          height: 280,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Text(
                      '시간 선택',
                      style: TextStyle(
                        color: AppColors.mainBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTime = TimeOfDay(
                            hour: tempHour,
                            minute: tempMinute,
                          );
                        });

                        notifyChanged();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          color: AppColors.mainBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: CupertinoPicker.builder(
                            scrollController: hourController,
                            itemExtent: 36,
                            diameterRatio: 1.2,
                            magnification: 1.1,
                            useMagnifier: true,
                            backgroundColor: AppColors.white,
                            onSelectedItemChanged: (index) {
                              tempHour = index % 24;
                            },
                            childCount: null,
                            itemBuilder: (context, index) {
                              final hour = index % 24;

                              return Center(
                                child: Text(
                                  hour.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontSize: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 8),
                        const Text(
                          ':',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),

                        SizedBox(
                          width: 80,
                          child: CupertinoPicker.builder(
                            scrollController: minuteController,
                            itemExtent: 36,
                            diameterRatio: 1.2,
                            magnification: 1.1,
                            useMagnifier: true,
                            backgroundColor: AppColors.white,
                            onSelectedItemChanged: (index) {
                              tempMinute = index;
                            },
                            childCount: null,
                            itemBuilder: (context, index) {
                              final minute = index % 60;

                              return Center(
                                child: Text(
                                  minute.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontSize: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    hourController.dispose();
    minuteController.dispose();
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  List<Widget> buildDateCells() {
    final firstDay = DateTime(
      visibleMonth.year,
      visibleMonth.month,
      1,
    );

    final daysCount = daysInMonth(visibleMonth);

    // DateTime.weekday: Mon=1, Tue=2, ..., Sun=7
    // Sunday start calendar, so if Sunday, 0 empty cells
    final leadingEmptyCells = firstDay.weekday % 7;

    final totalCells = leadingEmptyCells + daysCount;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(totalCells, (index) {
      if (index < leadingEmptyCells) {
        return const SizedBox();
      }

      final day = index - leadingEmptyCells + 1;
      final date = DateTime(visibleMonth.year, visibleMonth.month, day);
      final isSelected = isSameDate(date, selectedDate);
      final isToday = isSameDate(date, today);
      final isPast = date.isBefore(today);

      return InkWell(
        onTap: isPast
            ? null
            : () {
                setState(() {
                  selectedDate = date;
                });
                notifyChanged();
              },
        child: Opacity(
          opacity: isPast ? 0.3 : 1.0,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.dateBlue : AppColors.transparent,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: isSelected ? 17 : 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected || isToday
                      ? AppColors.logoBlue
                      : AppColors.black,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CalendarBubblePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month header
            Row(
              children: [
                Text(
                  '${months[visibleMonth.month - 1]} ${visibleMonth.year}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: 1),
                const Spacer(),
                GestureDetector(
                  onTap: goPreviousMonth,
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppColors.logoBlue,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: goNextMonth,
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.logoBlue,
                    size: 17,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Weekdays
            SizedBox(
              height: 12,
              child: Row(
                children: weekDays.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Dates
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              padding: EdgeInsets.zero,
              children: buildDateCells(),
            ),

            const Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.bottNavTextGrey,
            ),

            SizedBox(
              height: 36,
              child: Row(
                children: [
                  const Text(
                    'Ends',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.outlineGrey,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        formatTime(selectedTime),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CalendarBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    const notchWidth = 16.0;
    const notchHeight = 10.0;

    final notchCenter = size.width / 2 + 45;
    final path = Path();

    path.moveTo(radius, notchHeight);

    // path.lineTo(notchCenter - notchWidth / 2, notchHeight);
    // path.lineTo(notchCenter, 0);
    // path.lineTo(notchCenter + notchWidth / 2, notchHeight);

    path.lineTo(size.width - radius, notchHeight);

    path.quadraticBezierTo(
      size.width,
      notchHeight,
      size.width,
      notchHeight + radius,
    );

    path.lineTo(size.width, size.height - radius);

    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    path.lineTo(radius, size.height);

    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - radius,
    );

    path.lineTo(0, notchHeight + radius);

    path.quadraticBezierTo(
      0,
      notchHeight,
      radius,
      notchHeight,
    );

    path.close();

    final fillPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.black
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
