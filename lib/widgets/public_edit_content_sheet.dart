import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_dropdown_menu.dart';
import 'package:std/widgets/plus_page_calendar.dart';
import 'package:std/services/url_verification.dart';
import 'package:std/snackbar.dart';

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

  final GlobalKey _calendarAnchorKey = GlobalKey();

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

    final rawtitle = targetItem?.title ?? "";
    final titleText = rawtitle.trim().toLowerCase() == 'null' ? "" : rawtitle;
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

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
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
                    final verifier = UrlVerification();
                    late final String verifiedUrl;

                    try {
                      verifiedUrl = verifier.urlVerify(urlController.text);
                    } on FormatException catch (e) {
                      showCustomSnackBar(
                        context,
                        message: e.message,
                        isError: true,
                      );
                      return;
                    } catch (_) {
                      showCustomSnackBar(
                        context,
                        message: 'URL을 확인하는 중 문제가 발생했어요.',
                        isError: true,
                      );
                      return;
                    }
                    context.read<AppState>().updateContent(
                      id: widget.contentID,
                      newTitle: titleController.text,
                      newUrl: verifiedUrl,
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
                  Text(
                    _dateController.text.isEmpty ||
                            _dateController.text == 'null'
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
                  Transform.translate(
                    offset: const Offset(-3, 25),
                    child: Container(
                      key: _calendarAnchorKey,
                    ),
                  ),

                  Builder(
                    builder: (buttonContext) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque, // 빈 공간 터치 방지용
                        onTap: () {
                          final anchorContext =
                              _calendarAnchorKey.currentContext;

                          if (anchorContext != null) {
                            DateTime? parsedDate = DateTime.tryParse(
                              _dateController.text,
                            );
                            showLinkyCalendarPicker(
                              anchorContext,
                              initialDate: parsedDate ?? DateTime.now(),
                              onChanged: (date) {
                                setState(() {
                                  _dateController.text = DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(date);
                                });
                              },
                            );
                          }
                        },
                        child: Image.asset('assets/images/CalendarIcon.png'),
                      );
                    },
                  ),
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
      width: screenSize.width * 0.86,
      padding: EdgeInsets.symmetric(horizontal: 19, vertical: 14),
      child: insideWidget,
    );
  }
}
