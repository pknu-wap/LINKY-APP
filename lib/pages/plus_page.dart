import 'dart:async'; // 🌟 추가 (타임아웃 핸들링용)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/services/url_verification.dart';
import 'package:std/snackbar.dart';
import 'package:std/widgets/public_dropdown_menu.dart';
import '../main.dart';
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
  DateTime? selectedDate;
  int hour = 0;
  int minute = 0;

  @override
  void dispose() {
    urlController.dispose();
    titleController.dispose();
    super.dispose();
  }

  // 🌟 구조 개편된 안전한 저장 로직
  Future<void> saveLink() async {
    final url = urlController.text.trim();
    final title = titleController.text.trim();
    final verifier = UrlVerification();
    

    if (title.isEmpty) {
      showCustomSnackBar(context, message: '제목을 입력해주세요', isError: true);
      return;
    }
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

    final accessToken = await storage.read(key: 'accessToken');
    final kakaoId = await storage.read(key: 'kakaoId');

    if (kakaoId == null) {
      showCustomSnackBar(context, message: '로그인 정보가 유실되었습니다. 다시 로그인 해주세요.', isError: true);
      return;
    }

    // 2. 화면 선제 로딩 시작
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final serverUrl = Uri.parse("${baseUrl}/links"); 
      print("🚀 [서버 요청 전송] 주소: $serverUrl");
      
      final response = await http.post(
        serverUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: json.encode({
          "kakaoId": kakaoId, // 🌟 필수 추가: 서버 DTO에 맞는 유저 식별 식별자 변수명
          "url": url,
          "title": title,
          "category": selectedCategory ?? "전체", // null 방어
          "isPrivate": isPrivate,
          "selectedDate": selectedDate?.toIso8601String(), 
        }),
      ).timeout(const Duration(seconds: 5)); // 🌟 5초 타임아웃 안전망

      await context.read<AppState>().addContent(title: title, url: verifiedUrl, isPrivate: isPrivate, selectedDate: selectedDate);

      // 3. 통신이 완료되면 에러/성공 상관없이 일단 로딩팝업 먼저 무조건 닫기
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print("ℹ️ [서버 응답 수신] 상태 코드: ${response.statusCode}");
      print("ℹ️ [서버 응답 본문]: ${response.body}");

      // 4. 서버 응답 결과 판별
      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar(context, message: '링크가 성공적으로 DB에 저장되었습니다!');

        if (selectedDate != null) {
          addEventToMap(0, title, selectedDate!); 
        }

        // 입력 폼 클리어
        if (mounted) {
          setState(() {
            urlController.clear();
            titleController.clear();
            selectedCategory = null;
            isPrivate = false;
            selectedDate = null;
          });

          widget.onSaved?.call();
        }
      } else {
        // 백엔드 에러 코드 핸들링 (400, 404, 500 등)
        throw HttpException('서버가 요청을 거부했습니다. 코드: ${response.statusCode}');
      }

    } catch (e) {
      // 5. 예외 캐치 시 아직 로딩창이 열려있다면 즉시 닫아서 앱 먹통 방지
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print("🚨 [PlusPage 저장 에러 로그]: $e");

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (e is TimeoutException) {
        errorMessage = "서버 연결 시간이 초과되었습니다. (AWS 보안그룹 또는 포트 점검 필요)";
      }

      if (mounted) {
        showCustomSnackBar(
          context,
          message: '저장 실패: $errorMessage',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categoryList = appState.categories;

    return Scaffold(
      backgroundColor: AppColors.mainBackGrey,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                                Image.asset(
                                  'assets/images/linky_logo.png',
                                  width: 50,
                                  height: 65,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.link, size: 50),
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
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.inter(
                                color: AppColors.textGrey,
                              ),
                              labelText: '링크 URL',
                              hintText: 'https://example.com',
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
                            padding: const EdgeInsets.only(left: 13, right: 12),
                            height: 56,
                            child: DropdownWidget(
                              itemsList: categoryList,
                              onCategorySelected: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                              menuWidget: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedCategory ?? '카테고리',
                                    style: GoogleFonts.inter(
                                      color: selectedCategory == '카테고리' ||
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

// 명시적인 에러 처리를 위한 커스텀 예외 클래스
class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}