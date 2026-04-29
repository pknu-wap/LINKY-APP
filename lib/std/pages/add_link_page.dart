import 'package:flutter/material.dart';
import '../widgets/calendar.dart';
import '../widgets/category.dart';
import 'package:google_fonts/google_fonts.dart';

class AddLinkPage extends StatefulWidget {
  const AddLinkPage({super.key});

  @override
  State<AddLinkPage> createState() => _AddLinkPageState();
}

class _AddLinkPageState extends State<AddLinkPage> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  String? selectedCategory;
  bool isPrivate = false;
  DateTime? selectedDate;

  final List<String> categories = ['공부', '쇼핑', '취미', '검색', '설문'];

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

    if(RegExp(r'\s').hasMatch(url)) {
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
    ).showSnackBar(const SnackBar(content: Text('http 또는 https 링크만 입력할 수 있어요.')));
    return;
  }

    final uri = Uri.tryParse(url);

    if(uri == null || uri.scheme != 'http' && uri.scheme != 'https' ||
    uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('유효한 URL을 입력하세요.')));
      return;
    }

    

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('링크가 저장되었다고 가정!')));

    print('url: $url');
    print('title: $title');
    print('category: $selectedCategory');
    print('isPrivate: $isPrivate');
    print('selectedDate: $selectedDate');

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
      backgroundColor: const Color(0xFFF0F2F6),
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
                            color: Color(0xFF232323),
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
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: urlController,
                    maxLength: 1024,
                    //maxLength: 2048,
                    decoration: InputDecoration(
                      labelText: '링크 URL',
                      hintText: 'https://example.com',
                      //counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
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
                      labelText: '제목',
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  CategoryWidget(
                    selectedCategory: selectedCategory,
                    categories: categories,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '나만 보기로 저장',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Color(0xff7F7F7F),
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
                        backgroundColor: Color(0xFF3FD966),
                        foregroundColor: Color(0xFF000000),
                        side: BorderSide(color: Colors.black),
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
