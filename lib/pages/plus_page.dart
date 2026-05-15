import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/services/data_service.dart';
import 'package:std/services/url_verification.dart';
import 'package:std/widgets/public_dropdown_menu.dart';
import '../widgets/plus_page_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final DataService _dataService = DataService();
String? selectedCategory;

void addEventToMap(int contentID, String title, DateTime selectedDate) {
  // 날짜 정규화 (시간/분/초를 제외한 날짜만)
  final dateKey = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  // 이벤트 생성 (전달받은 selectedDate의 시, 분 활용)
  final newEvent = Event(
    contentID,
    title,
    hour: selectedDate.hour,
    minute: selectedDate.minute,
  );
  // 데이터 추가 로직
  kEvents.update(
    dateKey,
    (existingEvents) => [...existingEvents, newEvent],
    ifAbsent: () => [newEvent],
  );

  print('데이터 추가 완료: $dateKey - ${newEvent.title}');
}

class PlusPage extends StatefulWidget {
  const PlusPage({super.key});

  @override
  State<PlusPage> createState() => _PlusPageState();
}

class _PlusPageState extends State<PlusPage> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final storage = const FlutterSecureStorage();

  String? selectedCategory;
  bool isPrivate = false;
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

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    try {
      verifier.urlVerify(url);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }

    // 로딩
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await context.read<AppState>().addContent(
        url: url,
        title: title,
        category: selectedCategory,
        isPrivate: isPrivate,
        selectedDate: selectedDate,
      );

      print(
        'url: $url\ntitle: $title\ncategory: $selectedCategory\nisPrivate: $isPrivate\nselectedDate: $selectedDate',
      );

      Navigator.pop(context); // 로딩 닫기

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크가 성공적으로 DB에 저장되었습니다!')),
      );

      // 필드 초기화
      setState(() {
        urlController.clear();
        titleController.clear();
        selectedCategory = null;
        isPrivate = false;
        selectedDate = null;
      });
    } catch (e) {
      Navigator.pop(context); // 로딩 닫기

      final errorMessage = e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categoryList = appState.categories;

    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: SafeArea(
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
                              Image.asset(
                                'assets/images/linky_logo.png',
                                width: 50,
                                height: 65,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LINKY',
                                style: GoogleFonts.inter(
                                  fontSize: 60,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
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

                        TextField(
                          controller: urlController,
                          maxLength: 1024,
                          //maxLength: 2048,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.inter(
                              color: AppColors.textGrey,
                            ),
                            labelText: '링크 URL',
                            hintText: 'https://example.com',
                            //counterText: '',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: titleController,
                          maxLength: 50,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.inter(
                              color: AppColors.textGrey,
                            ),
                            labelText: '제목',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.bottNavTextGrey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 13, right: 12),
                          height: 56,
                          child: DropdownWidget(
                            itemsList: categoryList,
                            onCategorySelected: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                            menuWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              side: BorderSide(color: AppColors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
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
    );
  }
}
