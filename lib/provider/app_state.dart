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

  String get displayTitle {

    final normalizedTitle = title.trim();
    
    if(normalizedTitle.isEmpty || normalizedTitle.toLowerCase() == 'null'){
      return '요약중입니다...';
    }
    return normalizedTitle;
  }

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

    try {
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
      
        for (final jsonMap in linkList) {
          final row = LinkResponse.fromJson(jsonMap);

          final id = row.id;
          final title = row.title?.trim() ?? '';
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
      print("로드 에러 발생: $e");
    }
  }

  List<int> getContentIdsByCategory(String categoryName) {
    if (categoryName == '전체' || categoryName == 'All') {
      return _contents
          .where((item) => !item.isPrivate)
          .map((item) => item.id)
          .toList();
    }
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
    return _contents
        .where((item) => !item.isPrivate && item.category == categoryName)
        .map((item) => item.id)
        .toList();
  }

  List<ContentItem> get privateContents =>
      _contents.where((item) => item.isPrivate).toList();

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

  Future<void> addContent(ContentItem item) async {
    final deviceUuid = await getDeviceUuid();

    try {
      final serverUrl = Uri.parse("$baseUrl/links");
      print("[서버 요청 전송] 주소: $serverUrl");

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

      print("[서버 응답 수신] 상태 코드: ${response.statusCode}");
      print("[서버 응답 본문]: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {

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

        final newItem = ContentItem(
          id: nextId,
          title: item.title,
          url: item.url,
          isPrivate: item.isPrivate,
          time: formattedTime,
          category: verifiedCategory,
        );

        _contents.add(newItem);

        if (parsedTime != null) {
          DateTime dateKey = DateTime(
            parsedTime.year,
            parsedTime.month,
            parsedTime.day,
          );

          kEvents.putIfAbsent(dateKey, () => []);
          kEvents[dateKey]!.add(
            Event(
              nextId,
              item.title,
              hour: parsedTime.hour,
              minute: parsedTime.minute,
            ),
          );

          await AlarmService.scheduleEventAlarm(
            contentID: nextId,
            title: item.title,
            scheduledTime: parsedTime,
          );
        }

        notifyListeners();
      } else {
        throw HttpException('서버가 요청을 거부했습니다. 코드: ${response.statusCode}');
      }
    } catch (e) {
      print("[AppState 저장 에러 로그]: $e");
      rethrow;
    }
  }

  Future<void> removeContent({required int id}) async {
    final deviceUuid = await getDeviceUuid();

    await deleteLink(id: id, deviceUuid: deviceUuid);

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
      if (newTime != null) {
        DateTime newDate = DateTime.parse(newTime);
        DateTime newDateKey = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
        );

        kEvents.putIfAbsent(newDateKey, () => []);

        kEvents[newDateKey]!.add(
          Event(id, newTitle, hour: newDate.hour, minute: newDate.minute),
        );
      }

      await AlarmService.cancelEventAlarm(id);

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

  List<Event> getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return kEvents[dateKey] ?? [];
  }

  void removeEvent(DateTime day, int contentID) {
    final dateOnly = DateTime(day.year, day.month, day.day);

    if (kEvents.containsKey(dateOnly)) {
      kEvents[dateOnly]!.removeWhere((event) => event.contentID == contentID);

      if (kEvents[dateOnly]!.isEmpty) {
        kEvents.remove(dateOnly);
      }
    }

    int index = _contents.indexWhere((item) => item.id == contentID);
    if (index != -1) {
      _contents[index].time = null;
    }

    AlarmService.cancelEventAlarm(contentID);

    notifyListeners();
  }
}
