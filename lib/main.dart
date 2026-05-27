import 'dart:async';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:provider/provider.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/pages/category_page.dart';
import 'package:std/pages/login_page.dart';
import 'package:std/pages/private_page.dart';
import 'package:std/pages/setting_page.dart';
import 'package:std/pages/plus_page.dart';
import 'package:std/provider/app_state.dart';
import 'package:std/services/url_verification.dart';
import 'package:std/widgets/secret_page_guard.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter/services.dart';
import 'package:std/snackbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const String baseUrl = "http://3.34.52.216:8080";
final serverUrl = Uri.parse("${baseUrl}/links"); 

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

  await KakaoSdk.init(
    nativeAppKey: '82e41c6f8193caa43b268cd5c33fe23a',
  );
  await AndroidAlarmManager.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
            print("Shared: getMediaStream ${value.map((f) => f.value).join(",")}");
            _handleSharedFiles(value);
          },
          onError: (err) {
            print("getIntentDataStream error: $err");
          },
        );

    // 🌟 수정 1: 첫 화면 빌드가 완벽히 끝난 후 초기 공유 링크를 처리하도록 시점 조절
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await handleInitialSharing();
      
      final kakaoId = await storage.read(key: 'kakaoId');
      if (kakaoId == null) {
        debugPrint('kakaoId 없음');
        return;
      }

      if (!mounted) return;
      await context.read<AppState>().loadContentsFromDb(kakaoId);
    });
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
      String sharedContentTitle = '공유된 콘텐츠';

      final lines = sharedData.split('\n');
      for (String text in lines) {
        if (text.trim().contains("http://") || text.trim().contains("https://")) {
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
      try {
        verifier.urlVerify(sharedLink);
      } on FormatException catch (e) {
        if (!mounted) return;
        showCustomSnackBar(context, message: e.message, isError: true);
        return;
      }

      if (!mounted) return;

      // 🌟 [서버 전송 로딩 시작]
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        
        final response = await http.post(
          serverUrl,
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "url": sharedLink,
            "title": sharedContentTitle,
            "category": "전체", 
            "isPrivate": false,
            "selectedDate": null, 
          }),
        ).timeout(const Duration(seconds: 5));

        // 🌟 수정 2: 로딩창을 닫기 전 화면이 여전히 살아있는지(mounted) 확인
        if (!mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context); 
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('url: $sharedLink\ntitle: $sharedContentTitle');
          showCustomSnackBar(context, message: '공유된 링크가 성공적으로 DB에 저장되었습니다!');
          
          // 저장 후 화면 갱신을 위해 DB 데이터를 새로고침 해줍니다.
          final kakaoId = await storage.read(key: 'kakaoId');
          if (kakaoId != null && mounted) {
            await context.read<AppState>().loadContentsFromDb(kakaoId);
          }
          
          if (mounted) setState(() {});
        } else {
          throw Exception('서버 에러 (코드: ${response.statusCode})');
        }
      } catch (e) {
        // 🌟 수정 3: 에러 발생 시에도 화면 존재 확인 후 로딩창 닫기
        if (!mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context); 
        }
        print("🚨 외부 공유 링크 서버 저장 실패: $e");
        
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
      const SecretGuardWrapperPw(child: PrivatePage()), // 커스텀 패스워드 (현재 0000)
      PlusPage(
        onSaved: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      const CalendarPage(),
      const SettingPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackButton();
      },
      child: Scaffold(
        extendBody: true,
        // 현재 인덱스에 맞는 페이지 표시
        body: IndexedStack(
          index: _selectedIndex,
          children: _buildPages(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(19),
              topLeft: Radius.circular(19),
            ),
            border: Border.all(color: AppColors.outlineGrey, width: 1),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(19),
              topRight: Radius.circular(19),
            ),
            child: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: AppColors.mainGreen,
              unselectedItemColor: AppColors.black,
              items: [
                BottomNavigationBarItem(
                  icon: _buildCommonItem(Icons.reorder, '카테고리', false),
                  activeIcon: _buildCommonItem(Icons.reorder, '카테고리', true),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildCommonItem(Icons.account_circle_outlined, '나만보기', false),
                  activeIcon: _buildCommonItem(Icons.account_circle_outlined, '나만보기', true),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: const SizedBox(
                    height: 45,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: AppColors.mainGreen,
                        size: 45,
                      ),
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildCommonItem(Icons.calendar_today_rounded, '리마인더', false),
                  activeIcon: _buildCommonItem(Icons.calendar_today_rounded, '리마인더', true),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildCommonItem(Icons.settings_outlined, '설정', false),
                  activeIcon: _buildCommonItem(Icons.settings_outlined, '설정', true),
                  label: '',
                ),
              ],
            ),
          ),
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
        Icon(
          icon,
          color: isSelected ? AppColors.mainGreen : AppColors.black,
          size: 25,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.mainGreen : AppColors.black,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}