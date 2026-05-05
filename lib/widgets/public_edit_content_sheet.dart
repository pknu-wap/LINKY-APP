import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_dropdown_menu.dart';
import 'package:std/widgets/plus_page_calendar.dart';

class EditContentSheet extends StatefulWidget {
  const EditContentSheet({super.key, required this.contentID});
  final int contentID;

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

  bool _isInitialized = false;
  String? _selectedCategory;

  // final DateTime _focusedDay = DateTime.now();
  // DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    urlController = TextEditingController();
    summaryController = TextEditingController();
    _dateController = TextEditingController();
    titleFocusNode = FocusNode();
    urlFocusNode = FocusNode();
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

    final appState = context.watch<AppState>();
    final categories = appState.categories;
    final targetItem = context.select<AppState, ContentItem?>(
      (state) => state.contentById(widget.contentID),
    );

    final titleText = targetItem?.title ?? "찾을 수 없음";
    final urlText = targetItem?.url ?? "찾을 수 없음";
    final datetimeText = targetItem?.time ?? "";
    final categoryText = targetItem?.category ?? "카테고리 선택";

    if (!_isInitialized && targetItem != null) {
      titleController.text = titleText;
      urlController.text = urlText;
      _dateController.text = datetimeText;
      _selectedCategory = targetItem.category;

      _isInitialized = true;
    }

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
                () {
                  context.read<AppState>().updateContent(
                    id: widget.contentID,
                    newTitle: titleController.text,
                    newUrl: urlController.text,
                    newTime: _dateController.text,
                    newCategory: _selectedCategory,
                  );
                  Navigator.pop(context);
                },
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
                    InkWell(
                      onTap: () => titleController.text = '',
                      child: Icon(
                        Icons.cancel_outlined,
                        color: AppColors.textGrey,
                      ),
                    ),
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
                    InkWell(
                      onTap: () => urlController.text = '',
                      child: Icon(
                        Icons.cancel_outlined,
                        color: AppColors.textGrey,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 선택된 날짜 텍스트 (없으면 '날짜 수정')
                Text(
                  _dateController.text.isEmpty || _dateController.text == 'null'
                      ? '날짜 수정'
                      : _dateController.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color:
                        _dateController.text.isEmpty ||
                            _dateController.text == 'null'
                        ? AppColors.textGrey
                        : AppColors.black,
                  ),
                ),
                // 아이콘을 클릭하면 팝업으로 캘린더를 띄움
                Builder(
                  builder: (buttonContext) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque, // 빈 공간 터치 방지용
                      onTap: () {
                        DateTime? parsedDate = DateTime.tryParse(
                          _dateController.text,
                        );

                        showLinkyCalendarPicker(
                          context,
                          initialDate: parsedDate ?? DateTime.now(),
                          onChanged: (date) {
                            setState(() {
                              _dateController.text = DateFormat(
                                'yyyy-MM-dd HH:mm',
                              ).format(date);
                            });
                          },
                        );
                      },
                      child: Image.asset('assets/images/CalendarIcon.png'),
                    );
                  },
                ),
                // PopupMenuButton<void>(
                //   padding: EdgeInsets.zero,
                //   position: PopupMenuPosition.under,
                //   offset: const Offset(0, 10),
                //   elevation: 4,
                //   color: Colors.white,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(16),
                //     side: BorderSide(color: Colors.grey.shade200),
                //   ),
                //   itemBuilder: (BuildContext context) => [
                //     PopupMenuItem<void>(
                //       enabled: false, // 메뉴 자체 클릭 방지
                //       child: SizedBox(
                //         width: 320, // 캘린더 크기 명시
                //         height: 380,
                //         child: CalendarWidget(
                //           selectedDate: _selectedDay,
                //           onChanged: (date) {
                //             setState(() {
                //               _selectedDay = date;
                //             });
                //           },
                //         ),
                //       ),
                //     ),
                //   ],
                //   child: Image.asset(
                //     'assets/images/calendar_img.png', // 이미지 경로
                //     width: 24, // 아이콘 크기에 맞춰 적절히 조절
                //     height: 24,
                //     fit: BoxFit.contain,
                //     // 이미지가 없을 때를 대비한 에러 처리 (선택사항)
                //     errorBuilder: (context, error, stackTrace) => const Icon(
                //       Icons.calendar_today,
                //       color: AppColors.textGrey,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: DropdownWidget(
              itemsList: categories,
              onCategorySelected: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              menuWidget: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedCategory ?? categoryText,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: categoryText == "카테고리 추가"
                            ? AppColors.textGrey
                            : AppColors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_outlined),
                ],
              ),
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
