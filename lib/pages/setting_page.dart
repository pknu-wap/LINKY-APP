import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:std/constants.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/pages/plus_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/widgets/public_appbar.dart';
import 'package:std/widgets/public_dropdown_menu.dart';
import 'package:std/widgets/public_messagebox.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final TextEditingController _categoryController = TextEditingController();

  String? selectedCategory;

  // 입력창 스타일을 위한 공통 함수
  InputDecoration inputBox(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.outlineGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.outlineGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.mainGreen),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categories = appState.categories;

    return Scaffold(
      backgroundColor: AppColors.mainBackGrey, // 연한 그레이 배경색
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              AppBarDesign(
                appbarText: 'Setting',
                appbarIcon: Icons.settings_outlined,
              ),
              const SizedBox(height: 25),

              // 카테고리 추가 섹션
              Row(
                children: [
                  const Icon(Icons.add, color: AppColors.mainGreen, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    "카테고리 추가",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(), // 고정 width(150) 대신 Spacer를 사용하는 것이 반응형에 좋습니다.
                  ElevatedButton(
                    onPressed: () {
                      String categoryValue = _categoryController.text.trim();
                      if (categoryValue.isNotEmpty) {
                        if (categories.contains(categoryValue)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이미 존재하는 카테고리입니다.')),
                          );
                          return;
                        }

                        context.read<AppState>().addCategory(categoryValue);

                        _categoryController.clear(); // 입력창 비우기
                        FocusScope.of(context).unfocus(); // 키보드 닫기
                        print("카테고리 추가 완료: $categoryValue");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.black,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("확인"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: inputBox("카테고리 입력해주세요."),
              ),
              const SizedBox(height: 20),

              // 카테고리 선택 드롭다운 박스
              // 1. 라벨 및 확인 버튼 섹션
              Row(
                children: [
                  const Icon(
                    Icons.remove,
                    color: AppColors.mainGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "카테고리 삭제", // TextField를 없앴으므로 '추가' 대신 '선택' 혹은 '설정'이 적절합니다.
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // 확인 버튼 클릭 시 로직
                      if (selectedCategory != null &&
                          selectedCategory != '카테고리' &&
                          selectedCategory != '전체' &&
                          selectedCategory != '즐겨찾기') {
                        //카테고리 삭제
                        context.read<AppState>().removeCategory(
                          selectedCategory!,
                        );

                        setState(() {
                          selectedCategory = '카테고리'; // 선택 초기화
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('카테고리를 먼저 선택해주세요. (전체, 즐겨찾기 제외)'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.black,
                      elevation: 0, // 입체감을 줄이려면 0, 원하시면 유지
                      side: BorderSide(
                        color: AppColors.lightGrey,
                        width: 1,
                      ), // 테두리 추가 가능
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("확인"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 56, // 일반적인 TextField의 기본 높이
                padding: const EdgeInsets.symmetric(horizontal: 16), // 내부 여백
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                  border: Border.all(
                    color: AppColors.lightGrey, // TextField 테두리 색상
                    width: 1.3,
                  ),
                ),
                child: DropdownWidget(
                  itemsList: categories,
                  onCategorySelected: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  menuWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategory ?? '카테고리를 선택하세요',
                        style: GoogleFonts.inter(
                          color:
                              selectedCategory == null ||
                                  selectedCategory == '카테고리' ||
                                  selectedCategory == '전체' ||
                                  selectedCategory == '즐겨찾기'
                              ? AppColors.textGrey
                              : AppColors.black,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 비밀번호 설정 섹션
              Row(
                children: const [
                  Icon(
                    Icons.account_circle,
                    color: AppColors.mainGreen,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "나만 보기 페이지 비밀 번호 설정",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                decoration: inputBox("비밀번호를 입력해주세요."),
              ),

              const Spacer(), // 하단 버튼을 아래로 밀어줌
              // 로그아웃 버튼
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return DialogPopup(
                        title: '로그아웃 하시겠어요?',
                        boxType: BoxType.warning,
                        onConfirm: () => print('로그아웃 완료'),
                        confirmText: '로그아웃',
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Center(
                    child: Text(
                      "로그아웃",
                      style: TextStyle(
                        color: AppColors.mainRed,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  // _showActionDialog(context, "탈퇴");
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return DialogPopup(
                        title: '탈퇴 하시겠어요?',
                        boxType: BoxType.warning,
                        onConfirm: () => showDialog(
                          context: context,
                          builder: (context) {
                            return DialogPopup(
                              title: "탈퇴시 LINLKY에 저장된\n모든 정보는 삭제됩니다.",
                              onConfirm: () => print('탈퇴 완료'),
                              confirmText: '탈퇴',
                              boxType: BoxType.warning,
                            );
                          },
                        ),
                        confirmText: '예',
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    // 클릭 상태에 따라 배경색 변경
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.lightGrey,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "탈퇴",
                      style: TextStyle(
                        color: AppColors.mainRed,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String actionText) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  "$actionText 하시겠어요?", // 예: "탈퇴 하시겠어요?"
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 하단 버튼 영역 구분선
              Container(height: 1, color: AppColors.lightGrey),
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          color: AppColors.mainBlue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // 세로 구분선
                  Container(width: 1, height: 50, color: AppColors.lightGrey),
                  // 액션 버튼 (전달받은 텍스트 사용)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // 여기서 actionText에 따라 분기 로직을 짤 수도 있고,
                        // 콜백 함수를 따로 넘겨받을 수도 있습니다.
                        print("$actionText 완료");
                        Navigator.pop(context);
                      },
                      child: Text(
                        actionText,
                        style: const TextStyle(
                          color: AppColors.mainRed,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
