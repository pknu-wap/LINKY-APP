import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:std/main.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:std/pages/calender_page.dart';
import 'package:std/services/alarm_service.dart';
import 'package:std/services/db_service.dart';

class ContentItem extends ChangeNotifier {
  final int id;
  String category;
  String title;
  String url;
  String? summary;
  String? time;
  bool isPrivate;
  bool isFavorite;

  ContentItem({
    required this.id,
    required this.title,
    required this.url,
    required this.time,
    this.category = '전체',
    this.summary,
    required this.isPrivate,
    this.isFavorite = false,
  });

  ContentItem.create({
    required this.title,
    required this.url,
    required this.time,
    this.category = '전체',
    this.summary,
    required this.isPrivate,
    this.isFavorite = false,
  }) : id = -1;

  void updateContent(String newTitle, String newUrl) {
    title = newTitle;
    url = newUrl;
    notifyListeners();
  }
}

class AppState extends ChangeNotifier {
  final List<String> _categories = ['전체', '즐겨찾기'];

  final List<ContentItem> _contents = [];

  final storage = const FlutterSecureStorage();

  List<String> get categories => _categories;
  List<ContentItem> get contents => _contents;

  Future<void> loadContentsFromDb() async {
    final deviceUuid = await getDeviceUuid();

    // print("UUUUUUUUUUUUID      $deviceUuid");

    try {
      // 만약 LinkResponse.fetchLinksFromApi() 가 static으로 잘 구현되어 있다면 그것을 쓰셔도 되지만,
      // DataService를 안 쓰기로 했으므로 안정성을 위해 아래와 같이 직접 HTTP 통신을 작성하는 것을 추천합니다.
      final serverUrl = Uri.parse("$baseUrl/links");

      final headers = {
        "Content-Type": "application/json",
        "X-Device-UUID": deviceUuid,
      };

      final response = await http.get(serverUrl, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> linkList = responseData['data'] ?? responseData;

        _contents.clear();
        kEvents.clear();

        // 💡 핵심 수정: row는 이제 Map이 아니라 LinkResponse 객체입니다!
        for (final jsonMap in linkList) {
          final row = LinkResponse.fromJson(jsonMap); // 객체화

          final id = row.id;
          final title = row.title ?? '제목 없음';
          final selectedDateText = row.selectedDate;

          _contents.add(
            ContentItem(
              id: id,
              title: title,
              url: row.url,
              category: row.category ?? '전체',
              isPrivate: row.isPrivate,
              summary: row.summary ?? '',
              time: selectedDateText,
            ),
          );

          if (selectedDateText != null && selectedDateText.isNotEmpty) {
            final selectedDate = DateTime.tryParse(selectedDateText);

            if (selectedDate != null) {
              final dateKey = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
              );

              kEvents.putIfAbsent(dateKey, () => []);
              kEvents[dateKey]!.add(
                Event(
                  id,
                  title,
                  hour: selectedDate.hour,
                  minute: selectedDate.minute,
                ),
              );
            }
          }
        }

        if (kEvents.isNotEmpty) {
          await AlarmService.syncEventsWithAlarms(
            kEvents.cast<DateTime, List<dynamic>>(),
          );
        }

        notifyListeners();
      } else {
        throw Exception("서버 조회 실패 코드: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 로드 에러 발생: $e");
    }
  }

  List<int> getContentIdsByCategory(String categoryName) {
    // '전체' 카테고리일 경우 모든 (비공개가 아닌) id 반환
    if (categoryName == '전체' || categoryName == 'All') {
      return _contents
          .where((item) => !item.isPrivate)
          .map((item) => item.id)
          .toList();
    }

    // '즐겨찾기' 카테고리일 경우
    if (categoryName == '즐겨찾기' || categoryName == 'Favorites') {
      return _contents
          .where((item) => !item.isPrivate && item.isFavorite)
          .map((item) => item.id)
          .toList();
    }

    if (categoryName == '나만보기') {
      return _contents
          .where((item) => item.isPrivate)
          .map((item) => item.id)
          .toList();
    }

    // 특정 일반 카테고리일 경우
    return _contents
        .where((item) => !item.isPrivate && item.category == categoryName)
        .map((item) => item.id) // 아이템 객체에서 id만 추출
        .toList(); // 리스트로 변환
  }

  // 비공개 아이템만 필터링해서 가져오기
  List<ContentItem> get privateContents =>
      _contents.where((item) => item.isPrivate).toList();

  // categories 관리 로직

  void addCategory(String categoryName) {
    if (!_categories.contains(categoryName)) {
      _categories.add(categoryName);
      notifyListeners();
    }
  }

  void removeCategory(String categoryName) {
    if (categoryName == '전체') return;
    _categories.remove(categoryName);

    for (var content in _contents) {
      if (content.category == categoryName) {
        content.category = '전체';
      }
    }
    notifyListeners();
  }

  void updateCategory({
    required String oldCategoryName,
    required String newCategoryName,
  }) {
    int categoryIndex = _categories.indexOf(oldCategoryName);
    _categories[categoryIndex] = newCategoryName;
    notifyListeners();
  }

  bool categoryNameCheck(String categoryName) {
    return _categories.contains(categoryName);
  }

  Future<String> getDeviceUuid() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceUuid = prefs.getString('device_uuid');

    if (deviceUuid == null) {
      deviceUuid = const Uuid().v4();
      await prefs.setString('device_uuid', deviceUuid);
    }

    return deviceUuid;
  }

  // contents 관리 로직
  Future<void> addContent(ContentItem item) async {
    final deviceUuid = await getDeviceUuid();

    try {
      final serverUrl = Uri.parse("$baseUrl/links");
      print("🚀 [서버 요청 전송] 주소: $serverUrl");

      // 1. 서버에 POST 요청
      final response = await http
          .post(
            serverUrl,
            headers: {
              "Content-Type": "application/json",
              "X-Device-UUID": deviceUuid,
            },
            body: json.encode({
              "url": item.url,
              "title": item.title,
              "category": item.category,
              "isPrivate": item.isPrivate,
              "selectedDate": item.time != null
                  ? DateTime.parse(item.time!).toIso8601String()
                  : null,
            }),
          )
          .timeout(const Duration(seconds: 5));

      print("ℹ️ [서버 응답 수신] 상태 코드: ${response.statusCode}");
      print("ℹ️ [서버 응답 본문]: ${response.body}");

      // 2. 응답 확인
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🌟 새 ID 자동 할당 로직: 리스트가 비어있으면 1, 아니면 기존 최대 ID + 1
        int nextId = 1;
        if (_contents.isNotEmpty) {
          nextId =
              _contents.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
        }

        final verifiedCategory = (_categories.contains(item.category))
            ? item.category
            : '전체';

        DateTime? parsedTime;
        if (item.time != null) parsedTime = DateTime.parse(item.time!);

        final formattedTime = parsedTime != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(parsedTime)
            : null;

        // 3. 갱신된 ID로 새로운 로컬 아이템 생성
        final newItem = ContentItem(
          id: nextId, // 생성한 nextId 삽입
          title: item.title,
          url: item.url,
          isPrivate: item.isPrivate,
          time: formattedTime,
          category: verifiedCategory,
        );

        _contents.add(newItem);

        // 4. 달력/리마인더 이벤트 맵(kEvents)에 추가 및 알람 설정
        if (parsedTime != null) {
          DateTime dateKey = DateTime(
            parsedTime.year,
            parsedTime.month,
            parsedTime.day,
          );

          kEvents.putIfAbsent(dateKey, () => []);
          kEvents[dateKey]!.add(
            Event(
              nextId, // 생성한 nextId 삽입
              item.title,
              hour: parsedTime.hour,
              minute: parsedTime.minute,
            ),
          );

          await AlarmService.scheduleEventAlarm(
            contentID: nextId, // 생성한 nextId 삽입
            title: item.title,
            scheduledTime: parsedTime,
          );
        }

        // 화면 갱신 알림
        notifyListeners();
      } else {
        throw HttpException('서버가 요청을 거부했습니다. 코드: ${response.statusCode}');
      }
    } catch (e) {
      print("🚨 [AppState 저장 에러 로그]: $e");
      // UI 쪽에서 이 에러를 잡아서 SnackBar를 띄울 수 있도록 에러를 다시 던집니다 (rethrow).
      rethrow;
    }
  }

  Future<void> removeContent({required int id}) async {
    final DeviceUuid = await getDeviceUuid();

    await deleteLink(id: id, deviceUuid: DeviceUuid);

    _contents.removeWhere((item) => item.id == id);

    kEvents.forEach((date, eventList) {
      eventList.removeWhere((event) => event.contentID == id);
    });

    kEvents.removeWhere((date, eventList) => eventList.isEmpty);

    await AlarmService.cancelEventAlarm(id);

    notifyListeners();
  }

  Future<void> updateContent({
    required int id,
    required String newTitle,
    required String newUrl,
    required String? newTime,
    String? newCategory,
  }) async {
    int index = _contents.indexWhere((item) => item.id == id);

    if (index != -1) {
      String? oldTimeStr = _contents[index].time;
      if (newTime == '') {
        newTime = null;
      }

      _contents[index].title = newTitle;
      _contents[index].url = newUrl;
      if (newTime != null) {
        _contents[index].time = newTime;
      }

      if (newCategory != null) {
        _contents[index].category = _categories.contains(newCategory)
            ? newCategory
            : '전체';
      }

      if (oldTimeStr != null) {
        DateTime oldDate = DateTime.parse(oldTimeStr);
        DateTime oldDateKey = DateTime(
          oldDate.year,
          oldDate.month,
          oldDate.day,
        );

        if (kEvents.containsKey(oldDateKey)) {
          kEvents[oldDateKey]!.removeWhere((event) => event.contentID == id);
          if (kEvents[oldDateKey]!.isEmpty) kEvents.remove(oldDateKey);
        }
      }

      // 새로운 이벤트 등록 (newTime이 있을 경우에만)
      if (newTime != null) {
        DateTime newDate = DateTime.parse(newTime);
        DateTime newDateKey = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
        );

        // 해당 날짜 리스트가 없으면 새로 만들고 이벤트 추가
        kEvents.putIfAbsent(newDateKey, () => []);

        // 중복 방지를 위해 안전하게 추가
        kEvents[newDateKey]!.add(
          Event(id, newTitle, hour: newDate.hour, minute: newDate.minute),
        );
      }

      await AlarmService.cancelEventAlarm(id);

      //새 알람 등록
      if (newTime != null) {
        await AlarmService.scheduleEventAlarm(
          contentID: id,
          title: newTitle,
          scheduledTime: DateTime.parse(newTime),
        );
      }

      notifyListeners();
    }
  }

  void toggleFavorite(ContentItem item) {
    item.isFavorite = !item.isFavorite;
    notifyListeners();
  }

  ContentItem? contentById(int id) => _contents.cast<ContentItem?>().firstWhere(
    (item) => item?.id == id,
    orElse: () => null,
  );

  // 일정 관리 로직

  List<Event> getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return kEvents[dateKey] ?? [];
  }

  void removeEvent(DateTime day, int contentID) {
    final dateOnly = DateTime(day.year, day.month, day.day);

    if (kEvents.containsKey(dateOnly)) {
      // 전역 변수 kEvents에서 해당 contentID를 가진 이벤트만 찾아서 삭제
      kEvents[dateOnly]!.removeWhere((event) => event.contentID == contentID);

      // 만약 해당 날짜에 데이터가 없으면 키 삭제
      if (kEvents[dateOnly]!.isEmpty) {
        kEvents.remove(dateOnly);
      }
    }

    // 아예 삭제하지 않고 contents 리스트에서 해당 아이템의 time만 null로 변경
    int index = _contents.indexWhere((item) => item.id == contentID);
    if (index != -1) {
      _contents[index].time = null;
    }

    AlarmService.cancelEventAlarm(contentID);

    notifyListeners();
  }
}
