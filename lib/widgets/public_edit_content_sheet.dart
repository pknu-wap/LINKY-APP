import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/pages/plus_page.dart';
import 'package:std/widgets/plus_page_category.dart';
import 'package:std/widgets/reminder_page_calender.dart';

class EditContentSheet extends StatefulWidget {
  const EditContentSheet({
    super.key,
    required this.category_page_title,
    required this.category_page_url,
  });
  final String category_page_title;
  final String category_page_url;

  @override
  State<EditContentSheet> createState() => _EditContentSheetState();
}

class _EditContentSheetState extends State<EditContentSheet> {
  late TextEditingController titleController;
  late TextEditingController urlController;
  late TextEditingController summaryController;
  late TextEditingController _dateController;
  late FocusNode titleFocusNode;
  late FocusNode urlFocusNode;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    urlController = TextEditingController();
    summaryController = TextEditingController();
    _dateController = TextEditingController();
    titleFocusNode = FocusNode();
    urlFocusNode = FocusNode();

    titleFocusNode.addListener(() {
      if (titleFocusNode.hasFocus && titleController.text.isEmpty) {
        setState(() {
          titleController.text = widget.category_page_title;
        });
      }
    });
    urlFocusNode.addListener(() {
      if (urlFocusNode.hasFocus && urlController.text.isEmpty) {
        setState(() {
          urlController.text = widget.category_page_url;
        });
      }
    });
  }

  @override
  void dispose() {
    // 사용이 끝난 컨트롤러는 해제해줍니다.
    titleController.dispose();
    urlController.dispose();
    summaryController.dispose();
    titleFocusNode.dispose();
    urlFocusNode.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.9,
      width: screenSize.width,
      decoration: BoxDecoration(
        color: AppColors.popupBackGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(
                Icons.close_rounded,
                AppColors.mainRed,
                () => Navigator.pop(context),
              ),
              _circleButton(
                Icons.check_rounded,
                AppColors.mainGreen,
                () => Navigator.pop(context),
              ),
            ],
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: titleController,
                        focusNode: titleFocusNode,
                        decoration: InputDecoration(
                          hintText: '제목 수정',
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.cancel_outlined, color: AppColors.textGrey),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: urlController,
                        focusNode: urlFocusNode,
                        decoration: InputDecoration(
                          hintText: "URL 수정",
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.cancel_outlined, color: AppColors.textGrey),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 선택된 날짜 텍스트 (없으면 '날짜 수정')
                Text(
                  _dateController.text.isEmpty ? '날짜 수정' : _dateController.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: _dateController.text.isEmpty
                        ? AppColors.textGrey
                        : AppColors.black,
                  ),
                ),
                // 아이콘을 클릭하면 팝업으로 캘린더를 띄움
                PopupMenuButton<void>(
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    'assets/images/calendar_img.png', // 이미지 경로
                    width: 24, // 아이콘 크기에 맞춰 적절히 조절
                    height: 24,
                    fit: BoxFit.contain,
                    // 이미지가 없을 때를 대비한 에러 처리 (선택사항)
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.calendar_today,
                      color: AppColors.textGrey,
                    ),
                  ),
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 10),
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<void>(
                      enabled: false, // 메뉴 자체 클릭 방지
                      child: SizedBox(
                        width: 320, // 캘린더 크기 명시
                        height: 380,
                        child: CalenderWidget(
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              String month = selectedDay.month
                                  .toString()
                                  .padLeft(2, '0');
                              String day = selectedDay.day.toString().padLeft(
                                2,
                                '0',
                              );
                              _dateController.text =
                                  "${selectedDay.year}.$month.$day";
                            });
                            Navigator.pop(context); // 날짜 선택 시 팝업 닫기
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                          eventLoader: (day) => [],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Row(
              children: [
                Expanded(
                  child: Text(
                    '카테고리 수정',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                CategoryWidget(
                  categories: categoryNames,
                  onCategorySelected: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '요약 수정',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                ),
                TextField(
                  controller: summaryController,
                  maxLines: 13,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(width: 0.33, color: AppColors.outlineGrey),
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _WhiteContainer extends StatelessWidget {
  const _WhiteContainer({
    required this.screenSize,
    required this.insideWidget,
  });

  final Size screenSize;
  final Widget insideWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: AppColors.white,
      ),
      // height: 101,
      width: screenSize.width * 0.86,
      padding: EdgeInsets.symmetric(horizontal: 19, vertical: 14),
      child: insideWidget,
    );
  }
}
