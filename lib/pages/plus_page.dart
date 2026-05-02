import 'package:flutter/material.dart';
import 'package:std/constants.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/pages/private_page.dart';
import 'package:std/widgets/puablic_dropdown_menu.dart';
// import 'package:mysql_client/mysql_client.dart';
import '../widgets/plus_page_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

// Future<void> dbConnector({
//   required String url,
//   required String title,
//   required String? category,
//   required bool isPrivate,
//   required DateTime? selectedDate,
// }) async {
//   print("Connecting to mysql server...");
//   try {
//     // MySQL 접속 설정
//     final conn = await MySQLConnection.createConnection(
//       host: 'your host name',
//       port: 0808,
//       userName: 'your user name',
//       password: 'your password',
//       databaseName: 'your database name', // optional
//     );

//     await conn.execute(
//       "INSERT INTO links (url, title, category, is_private, selected_date) VALUES (:url, :title, :category, :is_private, :date)",
//       {
//         "url": url,
//         "title": title,
//         "category": category ?? "미분류",
//         "is_private": isPrivate ? 1 : 0,
//         "date": selectedDate?.toIso8601String(), // 날짜를 문자열로 변환
//       },
//     );

//     print("DB 저장 완료!");
//     await conn.close();
//   } catch (e) {
//     print("DB 저장 실패: $e");
//     throw e; // 에러를 위로 던져서 UI에서 처리하게 함
//   }
// }
String selectedCategory = '카테고리';

void addEventToMap(String title, DateTime selectedDate) {
  // 날짜 정규화 (시간/분/초를 제외한 날짜만)
  final dateKey = DateTime.utc(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  // 이벤트 생성 (전달받은 selectedDate의 시, 분 활용)
  final newEvent = Event(
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

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void saveLink() {
    final url = urlController.text.trim();
    final title = titleController.text.trim();

    if (url.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크와 제목은 꼭 입력해야 해요.')));
      return;
    }

    if (RegExp(r'\s').hasMatch(url)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('공백 불가')));
      return;
    }

    final blockedScheme = RegExp(
      r'^(javacript|data|file|ftp|mailto):',
      caseSensitive: false,
    );

    if (blockedScheme.hasMatch(url)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(content: Text('http 또는 https 링크만 입력할 수 있어요.')),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        uri.scheme != 'http' && uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('유효한 URL을 입력하세요.')));
      return;
    }

    if (isPrivate == true) {
      private_contentsTitle.add(title);
      private_contentsURL.add(url);
    }
    if (!isPrivate) {
      categories_contentsTitle.add(title);
      categories_contentsURL.add(url);
    }
    addEventToMap(title, selectedDate ?? DateTime.now()); //리마인더에 이벤트 추가

    print('url: $url');
    print('title: $title');
    print('category: $selectedCategory');
    print('isPrivate: $isPrivate');
    print('selectedDate: $selectedDate');

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => const Center(child: CircularProgressIndicator()),
    // );

    // try {
    //   // DB 저장 실행
    //   dbConnector(
    //     url: url,
    //     title: title,
    //     category: selectedCategory,
    //     isPrivate: isPrivate,
    //     selectedDate: selectedDate,
    //   );

    //   Navigator.pop(context); // 로딩 닫기

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('링크가 성공적으로 DB에 저장되었습니다!')),
    //   );

    //   // 필드 초기화
    //   setState(() {
    //     urlController.clear();
    //     titleController.clear();
    //     selectedCategory = null;
    //     isPrivate = false;
    //     selectedDate = null;
    //   });
    // } catch (e) {
    //   Navigator.pop(context); // 로딩 닫기
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('저장 실패: $e')),
    //   );
    // }

    setState(() {
      urlController.clear();
      titleController.clear();
      selectedCategory = null;
      isPrivate = false;
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(20),
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
                      labelStyle: GoogleFonts.inter(color: AppColors.textGrey),
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
                      labelStyle: GoogleFonts.inter(color: AppColors.textGrey),
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
                      itemsList: categoryNames,
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
                    onPressed: pickDate,
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
                          Text('저장', style: GoogleFonts.inter(fontSize: 20)),
                        ],
                      ),
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