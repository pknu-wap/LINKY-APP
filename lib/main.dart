import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/services/refresh_database.dart';
import 'package:std/pages/private_page.dart';
import 'package:std/pages/setting_page.dart';
import 'package:std/pages/plus_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/services/url_verification.dart';
import 'package:std/widgets/secret_page_guard.dart';
import 'package:flutter/services.dart';
import 'package:std/snackbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'package:std/splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const String baseUrl = "http://3.34.52.216:8080";
final serverUrl = Uri.parse("$baseUrl/links");

enum LockWith { customPw, localAuth }

LockWith? lockWith;
String? customPw;

@pragma('vm:entry-point')
void alarmCallback(int id) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('linkylogo'),
    ),
  );

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

  await AndroidAlarmManager.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('is_first_run') ?? true) {
    await prefs.remove('lock_method');
    await prefs.remove('custom_pw');
    await prefs.setBool('is_first_run', false);
  }

  final savedMethod = prefs.getString('lock_method');
  lockWith = LockWith.values.asNameMap()[savedMethod];

  customPw = prefs.getString('custom_pw');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppState(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Linky',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashPage(),
      routes: {
        '/main': (context) => const MainScreen(),
      },
      //home: const MainScreen(),
      navigatorObservers: [RefreshDatabase()],
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final storage = const FlutterSecureStorage();
  int _selectedIndex = 0;
  DateTime? _lastBackPressedTime;
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? list;
  late String sharedLink;
  String? sharedContentTitle;

  @override
  void initState() {
    super.initState();

    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedFile> value) {
            setState(() {
              list = value;
            });
            print(
              "Shared: getMediaStream ${value.map((f) => f.value).join(",")}",
            );
            _handleSharedFiles(value);
          },
          onError: (err) {
            print("getIntentDataStream error: $err");
          },
        );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestAlarmAndNotificationPermissions();
      await handleInitialSharing();

      if (!mounted) return;
      await context.read<AppState>().loadContentsFromDb();
    });
  }

  Future<void> requestAlarmAndNotificationPermissions() async {
    final androidPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> _handleSharedFiles(List<SharedFile> value) async {
    try {
      if (value.isEmpty) {
        print('-------공유된 데이터 없음------');
        return;
      }

      final String sharedData = value.map((f) => f.value).join(",");

      if (sharedData.isEmpty) {
        print('---------내용 없음----------');
        return;
      }

      String sharedLink = '';
      String sharedContentTitle = '요약중입니다...';

      final lines = sharedData.split('\n');
      for (String text in lines) {
        if (text.trim().contains("http://") ||
            text.trim().contains("https://")) {
          sharedLink = text.trim();
        } else if (text.trim().isNotEmpty) {
          sharedContentTitle = text.trim();
        }
      }

      if (sharedLink.isEmpty) {
        print('-----URL을 찾을 수 없음------');
        return;
      }

      final verifier = UrlVerification();
      late final String verifiedSharedLink;
      try {
        verifiedSharedLink = verifier.urlVerify(sharedLink);
      } on FormatException catch (e) {
        if (!mounted) return;
        showCustomSnackBar(context, message: e.message, isError: true);
        return;
      }

      final deviceUuid = await context.read<AppState>().getDeviceUuid();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.mainGreen,
          ),
        ),
      );

      try {
        final response = await http
            .post(
              serverUrl,
              headers: {
                "Content-Type": "application/json",
                "X-Device-UUID": deviceUuid,
              },
              body: json.encode({
                "url": verifiedSharedLink,
                "title": sharedContentTitle,
                "category": "전체",
                "isPrivate": false,
                "selectedDate": null,
                "categories": context
                    .read<AppState>()
                    .categories
                    .where((category) => category != '전체' && category != '즐겨찾기')
                    .toList(),
              }),
            )
            .timeout(const Duration(seconds: 5));

        if (!mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('url: $sharedLink\ntitle: $sharedContentTitle');
          showCustomSnackBar(context, message: '공유된 링크가 성공적으로 DB에 저장되었습니다!');
          if (mounted) {
            await context.read<AppState>().loadContentsFromDb();
            context.read<AppState>().startSummaryPolling();
          }

          if (mounted) setState(() {});
        } else {
          throw Exception('서버 에러 (코드: ${response.statusCode})');
        }
      } catch (e) {
        if (!mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        print("외부 공유 링크 서버 저장 실패: $e");

        String errorMessage = e.toString().replaceAll('Exception: ', '');
        if (e is TimeoutException) {
          errorMessage = "서버 연결 시간이 초과되었습니다.";
        }

        if (mounted) {
          showCustomSnackBar(
            context,
            message: '저장 실패: $errorMessage',
            isError: true,
          );
        }
      }
    } catch (e) {
      print("공유 데이터 처리 중 치명적 에러 발생: $e");
    }
  }

  Future<void> handleInitialSharing() async {
    try {
      final value = await FlutterSharingIntent.instance.getInitialSharing();
      await _handleSharedFiles(value);
    } catch (e) {
      print("공유 데이터 처리 중 에러 발생: $e");
    }
  }

  List<Widget> _buildPages() {
    return [
      const CategoryPage(),
      SecretGuardWrapper(
        isSelected: _selectedIndex == 1,
        child: const PrivatePage(),
      ), // 커스텀 패스워드 (현재 0000)
      PlusPage(
        onSaved: () {
          setState(() {
            _selectedIndex = 0;
          });

          context.read<AppState>().loadContentsFromDb();
          context.read<AppState>().startSummaryPolling();
        },
      ),
      const CalendarPage(),
      SettingPage(),
    ];
  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    await context.read<AppState>().loadContentsFromDb();
  }

  void _handleBackButton() {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }
    final now = DateTime.now();

    if (_lastBackPressedTime == null ||
        now.difference(_lastBackPressedTime!) > const Duration(seconds: 2)) {
      _lastBackPressedTime = now;

      showCustomSnackBar(
        context,
        message: '종료하려면 한번더 누르세요',
        duration: Duration(seconds: 2),
      );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackButton();
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _buildPages(),
            ),
            if (!isKeyboardOpen)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  child: Container(
                    height: 87,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          // splashColor: AppColors.mainGreen,
                          // hoverColor: AppColors.mainGreen,
                          highlightColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: BottomNavigationBar(
                          elevation: 0,
                          backgroundColor: AppColors.white,
                          showSelectedLabels: false,
                          showUnselectedLabels: false,
                          type: BottomNavigationBarType.fixed,
                          currentIndex: _selectedIndex,
                          onTap: _onItemTapped,
                          items: [
                            BottomNavigationBarItem(
                              icon: _buildCommonItem(
                                Icons.view_agenda_outlined,
                                '카테고리',
                                false,
                              ),
                              activeIcon: _buildCommonItem(
                                Icons.view_agenda_outlined,
                                '카테고리',
                                true,
                              ),
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
                              icon: _buildPlusItem(false),
                              activeIcon: _buildPlusItem(true),
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
                              icon: _buildCommonItem(
                                Icons.settings_outlined,
                                '설정',
                                false,
                              ),
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Widget _buildCommonItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.iconGreen : AppColors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.bottNavTextGrey.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.black,
              size: 25,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.iconGreen : AppColors.black,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPlusItem(bool isSelected) {
    return Transform.translate(
      offset: const Offset(0, -4),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainGreen : AppColors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.bottNavTextGrey.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: isSelected ? AppColors.white : AppColors.mainGreen,
            size: 47,
          ),
        ),
      ),
    );
  }
}
