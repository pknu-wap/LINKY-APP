import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/services/url_verification.dart';
import 'package:std/snackbar.dart';
import 'package:std/widgets/public_dropdown_menu.dart';
import '../widgets/plus_page_calendar.dart';

String? selectedCategory;

void addEventToMap(int contentID, String title, DateTime selectedDate) {
  final dateKey = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final newEvent = Event(
    contentID,
    title,
    hour: selectedDate.hour,
    minute: selectedDate.minute,
  );
  kEvents.update(
    dateKey,
    (existingEvents) => [...existingEvents, newEvent],
    ifAbsent: () => [newEvent],
  );
  print('데이터 추가 완료: $dateKey - ${newEvent.title}');
}

class PlusPage extends StatefulWidget {
  final VoidCallback? onSaved;

  const PlusPage({super.key, this.onSaved});

  @override
  State<PlusPage> createState() => _PlusPageState();
}

class _PlusPageState extends State<PlusPage> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final storage = const FlutterSecureStorage();

  String? selectedCategory;
  bool isPrivate = false;
  bool isCategoryFocused = false;
  DateTime? selectedDate;
  int hour = 0;
  int minute = 0;

  @override
  void dispose() {
    urlController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<void> saveLink() async {
    final url = urlController.text.trim();
    final title = titleController.text.trim();
    final verifier = UrlVerification();

    // if (title.isEmpty) {
    //   showCustomSnackBar(context, message: '제목을 입력해주세요', isError: true);
    //   return;
    // }
    late final String verifiedUrl;
    try {
      verifiedUrl = verifier.urlVerify(url);
    } on FormatException catch (e) {
      showCustomSnackBar(context, message: e.message, isError: true);
      return;
    } catch (_) {
      showCustomSnackBar(
        context,
        message: 'URL을 확인하는 중 문제가 발생했어요',
        isError: true,
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.mainGreen),
      ),
    );

    final newItem = ContentItem.create(
      title: title,
      url: verifiedUrl,
      time: selectedDate?.toString(),
      isPrivate: isPrivate,
      category: selectedCategory ?? "전체",
    );

    try {
      await context.read<AppState>().addContent(newItem);

      if (!mounted) return;

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      showCustomSnackBar(context, message: '링크가 성공적으로 저장되었습니다!');

      setState(() {
        urlController.clear();
        titleController.clear();
        selectedCategory = null;
        isPrivate = false;
        isCategoryFocused = false;
        selectedDate = null;
      });

      widget.onSaved?.call();
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // 로딩창 닫기
      }

      print("[PlusPage 저장 에러 로그]: $e");

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (e is TimeoutException) {
        errorMessage = "서버 연결 시간이 초과되었습니다.";
      }

      showCustomSnackBar(
        context,
        message: '저장 실패: $errorMessage',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categoryList = appState.categories
        .where((item) => item != '즐겨찾기')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            isCategoryFocused = false;
          });
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 60,
                                  child: Image.asset(
                                    'assets/images/linky_logo.png',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Transform.translate(
                                  offset: Offset(0, 4),
                                  child: Text(
                                    'LINKY',
                                    style: GoogleFonts.lalezar(
                                      fontSize: 70,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '새 링크 저장',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: TextSelectionThemeData(
                                cursorColor: AppColors.mainGreen,
                                selectionColor: AppColors.mainGreen.withValues(
                                  alpha: 0.3,
                                ),
                                selectionHandleColor: AppColors.mainGreen,
                              ),
                            ),
                            child: TextField(
                              controller: urlController,
                              maxLength: 1024,
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.inter(
                                  color: AppColors.textGrey,
                                ),
                                labelText: '링크 URL',
                                hintText: 'https://example.com',
                                filled: true,
                                fillColor: AppColors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.bottNavTextGrey,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.mainGreen,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: TextSelectionThemeData(
                                cursorColor: AppColors.mainGreen,
                                selectionColor: AppColors.mainGreen.withValues(
                                  alpha: 0.3,
                                ),
                                selectionHandleColor: AppColors.mainGreen,
                              ),
                            ),
                            child: TextField(
                              controller: titleController,
                              maxLength: 50,
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.inter(
                                  color: AppColors.textGrey,
                                ),
                                labelText: '제목',
                                filled: true,
                                fillColor: AppColors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.bottNavTextGrey,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.mainGreen,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: isCategoryFocused
                                    ? AppColors.mainGreen
                                    : AppColors.bottNavTextGrey,
                                width: isCategoryFocused ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 13,
                              right: 12,
                            ),
                            height: 56,
                            child: DropdownWidget(
                              itemsList: categoryList,
                              onOpend: () {
                                setState(() {
                                  isCategoryFocused = true;
                                });
                              },
                              onCanceled: () {
                                setState(() {
                                  isCategoryFocused = false;
                                });
                              },
                              onCategorySelected: (value) {
                                setState(() {
                                  selectedCategory = value;
                                  isCategoryFocused = false;
                                });
                              },
                              menuWidget: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedCategory ?? '카테고리',
                                    style: GoogleFonts.inter(
                                      color:
                                          selectedCategory == '카테고리' ||
                                              selectedCategory == null
                                          ? AppColors.textGrey
                                          : AppColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down_outlined),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '나만 보기로 저장',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: isPrivate,
                                  activeThumbColor: AppColors.mainGreen,
                                  activeTrackColor: AppColors.mainGreen
                                      .withValues(alpha: 0.4),
                                  inactiveThumbColor: AppColors.bottNavTextGrey,
                                  inactiveTrackColor: AppColors.white,
                                  trackOutlineColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(
                                            WidgetState.selected,
                                          )) {
                                            return AppColors.mainGreen;
                                          }
                                          return AppColors.bottNavTextGrey;
                                        },
                                      ),
                                  trackOutlineWidth:
                                      WidgetStateProperty.resolveWith<double?>(
                                        (states) {
                                          if (states.contains(
                                            WidgetState.selected,
                                          )) {
                                            return 1.5;
                                          }
                                          return 1.5;
                                        },
                                      ),
                                  onChanged: (value) {
                                    setState(() {
                                      isPrivate = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 75),
                          CalendarWidget(
                            selectedDate: selectedDate,
                            onChanged: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: saveLink,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.mainGreen,
                                foregroundColor: AppColors.black,
                                side: const BorderSide(color: AppColors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '저장',
                                    style: GoogleFonts.inter(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
