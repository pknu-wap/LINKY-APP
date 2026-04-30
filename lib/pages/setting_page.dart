import 'package:flutter/material.dart';
import 'package:std/pages/plus_page.dart';
import 'package:std/widgets/public_select_category.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final TextEditingController _categoryController = TextEditingController();
  // 입력창 스타일을 위한 공통 함수
  InputDecoration inputBox(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF3FD966)),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // 연한 그레이 배경색
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFBFF3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Setting",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // 카테고리 추가 섹션
              Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF3FD966), size: 28),
                  SizedBox(width: 8),
                  Text(
                    "카테고리 추가",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 150),
                  ElevatedButton(
                    onPressed: () {
                      String categoryValue = _categoryController.text.trim();

                      SelectCategory(
                        categoryCount: categoryValue.length.toString(),
                        categoryTitle: categoryValue,
                      );

                      if (categoryValue.isNotEmpty) {
                        if (categories.contains(categoryValue)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이미 존재하는 카테고리입니다.')),
                          );
                          return;
                        }

                        setState(() {
                          categories.add(categoryValue);
                        });

                        _categoryController.clear(); // 입력창 비우기
                        FocusScope.of(context).unfocus(); // 키보드 닫기

                        print("카테고리 추가 완료: $categories");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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
              const SizedBox(height: 35),
              // 비밀번호 설정 섹션
              Row(
                children: const [
                  Icon(
                    Icons.account_circle,
                    color: Color(0xFF3FD966),
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
                  _showLogoutDialog(context);
                  print("로그아웃 버튼 클릭");
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      "로그아웃",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

  void _showLogoutDialog(BuildContext context) {
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  "로그아웃 하시겠어요?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              // 하단 버튼 영역 구분선
              Container(height: 1, color: Colors.grey[200]),
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "취소",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ),
                  // 가로 구분선
                  Container(width: 1, height: 50, color: Colors.grey[200]),
                  // 로그아웃 버튼
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // 실제 로그아웃 로직 실행 부분
                        print("로그아웃 완료");
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "로그아웃",
                        style: TextStyle(color: Colors.red, fontSize: 16),
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
