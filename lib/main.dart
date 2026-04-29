import 'package:flutter/material.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/pages/private_page.dart';
import 'package:std/pages/setting.dart';
import 'package:std/pages/slidepage.dart';
import 'package:std/std/pages/add_link_page.dart';
import 'package:std/std/pages/login.dart';
import 'package:std/widgets/secretpage_guard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Linky',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭의 인덱스
  int _selectedIndex = 0;

  // 이동할 페이지 리스트
  final List<Widget> _pages = [
    const CategoryPage(),
    const SecretGuardWrapperPw(child: PrivatePage()), // 커스텀 패스워드 (현재 0000)
    const AddLinkPage(),
    const Slidepage(),
    const Setting(),
  ];

  // 탭 클릭 시 인덱스 변경 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // 현재 인덱스에 맞는 페이지 표시
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(19),
            topLeft: Radius.circular(19),
          ),
          border: Border.all(color: Color(0xffC4C4C4), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(19),
            topRight: Radius.circular(19),
          ),
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Color(0xff3fd966),
            unselectedItemColor: Colors.black,
            items: [
              BottomNavigationBarItem(
                icon: _buildCommonItem(Icons.reorder, '카테고리', false),
                activeIcon: _buildCommonItem(Icons.reorder, '카테고리', true),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildCommonItem(
                  Icons.account_circle_outlined,
                  '나만보기',
                  false,
                ),
                activeIcon: _buildCommonItem(
                  Icons.account_circle_outlined,
                  '나만보기',
                  true,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  height: 45, // 조정 필요
                  child: const Center(
                    child: Icon(Icons.add, color: Color(0xff3fd966), size: 45),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildCommonItem(
                  Icons.calendar_today_rounded,
                  '리마인더',
                  false,
                ),
                activeIcon: _buildCommonItem(
                  Icons.calendar_today_rounded,
                  '리마인더',
                  true,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildCommonItem(Icons.settings_outlined, '설정', false),
                activeIcon: _buildCommonItem(
                  Icons.settings_outlined,
                  '설정',
                  true,
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xff3fd966) : Colors.black,
          size: 25,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xff3fd966) : Colors.black,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
