import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:std/pages/calender.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/pages/private_page.dart';
import 'package:std/pages/setting.dart';
import 'package:std/pages/slidepage.dart';
import 'package:std/services/alarm_service.dart';
import 'package:std/std/pages/add_link_page.dart';
//import 'package:std/std/pages/login.dart';
import 'package:std/widgets/secretpage_guard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void alarmCallback(int id) async {
  // 1. 플러플 플러그인 인스턴스 생성
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  // 2. 초기화 설정을 변수로 분리하여 확실히 적용
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('linkylogo'); // 앱 아이콘 사용

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  try {
    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // 알림 클릭 시 로직
      },
    );

    // 3. 알림 상세 설정 (채널 ID를 매번 고유하게 가져가거나 아주 새로운 이름으로 변경)
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_priority_alarm_channel_unique',
          '실시간 일정 알림',
          channelDescription: '정해진 시간에 알림을 띄웁니다.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          largeIcon: const DrawableResourceAndroidBitmap('linkylogo'),
          styleInformation: const BigTextStyleInformation(''),
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // 4. 알림 표시
    await plugin.show(
      id,
      '일정 리마인더',
      '예약하신 일정이 지금 시작됩니다! (ID: $id)',
      notificationDetails,
    );
  } catch (e) {
    print("알림 표시 중 에러 발생: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 알람 매니저 초기화
  await AndroidAlarmManager.initialize();

  // 2. kEvents 데이터 자동 동기화 (앱 실행 시마다 수행)
  // 데이터가 있는 위치에 맞춰 kEvents를 넣어주세요.
  await AlarmService.syncEventsWithAlarms(kEvents);

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
      home: const MainScreen(),
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
