import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:std/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:std/pages/calender_page.dart';
import 'package:std/services/alarm_service.dart';
import 'package:std/services/data_service.dart';
import 'package:std/services/link_model.dart';

class ContentItem extends ChangeNotifier {
  final int id;
  String category;
  String title;
  String url;
  String summary;
  String? time;
  bool isPrivate;
  bool isFavorite;

  ContentItem({
    required this.id,
    required this.title,
    required this.url,
    required this.time,
    this.category = '전체',
    this.summary = '',
    required this.isPrivate,
    this.isFavorite = false,
  });

  void updateContent(String newTitle, String newUrl) {
    title = newTitle;
    url = newUrl;
    notifyListeners();
  }
}

class AppState extends ChangeNotifier {
  final List<String> _categories = ['전체', '즐겨찾기'];
  final DataService _dataService = DataService();

  final List<ContentItem> _contents = [];

  final storage = const FlutterSecureStorage();

  List<String> get categories => _categories;
  List<ContentItem> get contents => _contents;

  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await storage.read(key: 'accessToken');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };
  }

  Future<void> loadContentsFromDb() async {
    try {
      final serverUrl = Uri.parse("${baseUrl}/links");
      final headers = await _getHeaders();
      final response = await http.get(serverUrl, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> linkList = responseData['data'] ?? responseData;

        _contents.clear();
      
        for (final jsonMap in linkList) {
          final row = LinkResponse.fromJson(jsonMap);

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

  Future<void> addContent({
    required String title,
    required String url,
    required bool isPrivate,
    required DateTime? selectedDate,
    String? category,
  }) async {
    final kakaoId = await storage.read(key: 'kakaoId');
    if (kakaoId == null) {
      throw Exception('로그인 정보가 없습니다. 다시 로그인해주세요.');
    }
    final int dbId = await _dataService.insertLink(
      kakaoId: kakaoId,
      url: url,
      title: title,
      category: category,
      isPrivate: isPrivate,
      selectedDate: selectedDate,
    );

    final verifiedCategory =
        (category != null && _categories.contains(category)) ? category : '전체';

    final formattedTime = selectedDate != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)
        : null;

    final newItem = ContentItem(
      id: dbId,
      title: title,
      url: url,
      isPrivate: isPrivate,
      time: formattedTime,
      category: verifiedCategory,
    );

    _contents.add(newItem);

    if (selectedDate != null) {
      DateTime dateKey = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      kEvents.putIfAbsent(dateKey, () => []);
      kEvents[dateKey]!.add(
        Event(
          dbId,
          title,
          hour: selectedDate.hour,
          minute: selectedDate.minute,
        ),
      );

      await AlarmService.scheduleEventAlarm(
        contentID: dbId,
        title: title,
        scheduledTime: selectedDate,
      );
    }

    notifyListeners();
  }

  Future<void> removeContent({required int id, required String kakaoId}) async {
    await _dataService.deleteLink(id: id, kakaoId: kakaoId);

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
