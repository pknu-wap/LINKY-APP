import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/pages/login_page.dart';
import 'package:std/pages/private_page.dart';
import 'package:std/pages/setting_page.dart';
import 'package:std/pages/slide_page.dart';
import 'package:std/pages/plus_page.dart';
import 'package:std/services/alarm_service.dart';
import 'package:std/widgets/secret_page_guard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void alarmCallback(int id) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('linkylogo'),
    ),
  );

  // ID를 통해 30분 전인지 정시인지 판별
  bool isEarlyAlarm = (id % 2 == 0);
  String message = isEarlyAlarm
      ? "일정 시작 30분 전입니다! 준비하세요."
      : "설정하신 일정 시간이 되었습니다!";

  final androidDetails = AndroidNotificationDetails(
    'high_priority_alarm_channel_unique',
    '실시간 일정 알림',
    importance: Importance.max,
    priority: Priority.high,
    largeIcon: const DrawableResourceAndroidBitmap('linkylogo'),
  );

  await plugin.show(
    id,
    isEarlyAlarm ? '[사전 알림]' : '[일정 알림]',
    message,
    NotificationDetails(android: androidDetails),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 알람 매니저 초기화
  await AndroidAlarmManager.initialize();

  // 2. kEvents 데이터 자동 동기화 (앱 실행 시마다 수행)
  // 데이터가 있는 위치에 맞춰 kEvents를 넣어주세요.
  if (kEvents.isNotEmpty) {
    await AlarmService.syncEventsWithAlarms(
      kEvents.cast<DateTime, List<dynamic>>(),
    );
  } else {
    print("앱 실행 시 kEvents 데이터가 비어 있습니다.");
  }

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
    const PlusPage(),
    const Slidepage(),
    const SettingPage(),
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
