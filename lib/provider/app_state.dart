import 'dart:async';
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
  String? summaryStatus;
  String? time;
  bool isPrivate;
  bool isFavorite;

  String get displayTitle {
    final normalizedTitle = title.trim();

    if (normalizedTitle.isEmpty || normalizedTitle.toLowerCase() == 'null') {
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
    this.summaryStatus,
    required this.isPrivate,
    this.isFavorite = false,
  });

  ContentItem.create({
    required this.title,
    required this.url,
    required this.time,
    this.category = '전체',
    this.summary,
    this.summaryStatus,
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
  bool isLoadingContents = false;

  Timer? summaryPollingTimer;

  final List<String> _categories = ['전체', '즐겨찾기'];

  final List<ContentItem> _contents = [];

  final storage = const FlutterSecureStorage();

  List<String> get categories => _categories;
  List<ContentItem> get contents => _contents;

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', _categories);
  }

  // Future<void> resetCategories() async {
  //   _categories
  //     ..clear()
  //     ..addAll(['전체', '즐겨찾기']);

  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setStringList('categories', []);

  //   notifyListeners();
  // }

  Future<void> loadSavedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getStringList('categories') ?? [];

    _categories
      ..clear()
      ..addAll(['전체', '즐겨찾기']);

    for (final category in savedCategories) {
      if (!_categories.contains(category)) {
        _categories.add(category);
      }
    }
  }

  Future<void> loadContentsFromDb() async {
    if (isLoadingContents) return;
    isLoadingContents = true;

    try {
      final deviceUuid = await getDeviceUuid();
      final serverUrl = Uri.parse("$baseUrl/links");

      final headers = {
        "Content-Type": "application/json",
        "X-Device-UUID": deviceUuid,
      };

      final response = await http.get(serverUrl, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        final List<dynamic> linkList;
        if (responseData is Map<String, dynamic>) {
          linkList = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData is List<dynamic>) {
          linkList = responseData;
        } else {
          linkList = [];
        }

        _contents.clear();
        kEvents.clear();

        await loadSavedCategories();

        for (final jsonMap in linkList) {
          final row = LinkResponse.fromJson(jsonMap);

          final id = row.id;
          final title = row.title?.trim() ?? '';
          final selectedDateText = row.selectedDate;

          final category = row.category?.trim().isNotEmpty == true
              ? row.category!.trim()
              : '전체';

          if (category != '전체' &&
              category != '즐겨찾기' &&
              !_categories.contains(category)) {
            _categories.add(category);
          }

          _contents.add(
            ContentItem(
              id: id,
              title: title,
              url: row.url,
              category: category,
              isPrivate: row.isPrivate,
              isFavorite: row.isFavorite,
              summary: row.summary ?? '',
              summaryStatus: row.summaryStatus,
              time: selectedDateText?.replaceAll('T', ' '),
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
          final eventsSnapshot = Map<DateTime, List<dynamic>>.fromEntries(
            kEvents.entries.map(
              (entry) => MapEntry(
                entry.key,
                List<dynamic>.from(entry.value),
              ),
            ),
          );

          await AlarmService.syncEventsWithAlarms(eventsSnapshot);
        }

        final hasRunningSummary = _contents.any(
          (item) =>
              item.summaryStatus == 'PENDING' ||
              item.summaryStatus == 'PROCESSING',
        );

        if (hasRunningSummary) {
          startSummaryPolling();
        }

        notifyListeners();
      } else {
        throw Exception("서버 조회 실패 코드: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("로드 에러 발생: $e");
      print(stackTrace);
    } finally {
      isLoadingContents = false;
    }
  }

  void startSummaryPolling() {
    if (summaryPollingTimer?.isActive == true) return;

    summaryPollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        await loadContentsFromDb();

        final hasRunningSummary = _contents.any(
          (item) =>
              item.summaryStatus == 'PENDING' ||
              item.summaryStatus == 'PROCESSING',
        );

        if (!hasRunningSummary) {
          stopSummaryPolling();
        }
      },
    );
  }

  void stopSummaryPolling() {
    summaryPollingTimer?.cancel();
    summaryPollingTimer = null;
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

  Future<void> addCategory(String categoryName) async {
    final name = categoryName.trim();
    if (name.isEmpty) return;

    if (!_categories.contains(name)) {
      _categories.add(name);
      await saveCategories();
      notifyListeners();
    }
  }

  Future<void> removeCategory(String categoryName) async {
    if (categoryName == '전체' || categoryName == '즐겨찾기') return;

    final deviceUuid = await getDeviceUuid();
    final affectedContents = _contents
        .where((content) => content.category == categoryName)
        .toList();

    final results = await Future.wait(
      affectedContents.map((content) {
        return updateLink(
          id: content.id,
          deviceUuid: deviceUuid,
          title: content.title,
          url: content.url,
          category: '전체',
          isPrivate: content.isPrivate,
          selectedDate: content.time,
        );
      }),
    );

    if (results.contains(false)) {
      return;
    }

    for (final content in affectedContents) {
      content.category = '전체';
    }

    _categories.remove(categoryName);
    await saveCategories();
    notifyListeners();
  }

  Future<bool> updateCategory({
    required String oldCategoryName,
    required String newCategoryName,
  }) async {
    final categoryIndex = _categories.indexOf(oldCategoryName);

    if (categoryIndex == -1) {
      return false;
    }

    final affectedContents = _contents
        .where((item) => item.category == oldCategoryName)
        .toList();

    final deviceUuid = await getDeviceUuid();

    for (final item in affectedContents) {
      final success = await updateLink(
        id: item.id,
        deviceUuid: deviceUuid,
        title: item.title,
        url: item.url,
        category: newCategoryName,
        isPrivate: item.isPrivate,
        selectedDate: item.time,
      );
      if (!success) {
        return false;
      }
    }

    _categories[categoryIndex] = newCategoryName;

    for (final item in affectedContents) {
      item.category = newCategoryName;
    }

    await saveCategories();
    notifyListeners();
    return true;
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    saveCategories();
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

      // 서버에 POST 요청
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
              "isFavorite": item.isFavorite,
              "selectedDate": item.time != null
                  ? DateTime.parse(item.time!).toIso8601String()
                  : null,
              "categories": _categories
                  .where((category) => category != '전체' && category != '즐겨찾기')
                  .toList(),
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
          isFavorite: item.isFavorite,
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
    required String url,
    required String newTitle,
    required String? newTime,
    String? newCategory,
  }) async {
    int index = _contents.indexWhere((item) => item.id == id);

    if (index != -1) {
      String? oldTimeStr = _contents[index].time;
      if (newTime == '') {
        newTime = null;
      }

      final success = await updateLink(
        id: id,
        deviceUuid: await getDeviceUuid(),
        title: newTitle,
        url: url,
        category: newCategory ?? _contents[index].category,
        isPrivate: _contents[index].isPrivate,
        selectedDate: newTime,
      );

      if (!success) {
        print("콘텐츠 업데이트 실패: 서버 오류");
        return;
      }

      _contents[index].title = newTitle;
      _contents[index].url = url;
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

  Future<bool> updateLink({
    required int id,
    required String deviceUuid,
    required String title,
    required String url,
    required String category,
    required bool isPrivate,
    String? selectedDate,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/links/$id"),
      headers: {
        "Content-Type": "application/json",
        "X-Device-UUID": deviceUuid,
      },
      body: jsonEncode({
        "title": title,
        "url": url,
        "category": category,
        "isPrivate": isPrivate,
        "selectedDate": selectedDate != null
            ? DateTime.parse(selectedDate).toIso8601String()
            : null,
      }),
    );

    print("콘텐츠 수정 상태코드: ${response.statusCode}");
    print("콘텐츠 수정 응답: ${response.body}");

    return response.statusCode == 200;
  }

  Future<void> resetAllData() async {
    stopSummaryPolling();

    final deviceUuid = await getDeviceUuid();

    final success = await DbService().resetData(deviceUuid: deviceUuid);
    if (!success) {
      throw Exception('초기화 실패');
    }

    final contentIds = _contents.map((item) => item.id).toList();
    if (contentIds.isNotEmpty) {
      final cancelFutures = contentIds.map(
        (id) => AlarmService.cancelEventAlarm(id),
      );
      await Future.wait(cancelFutures);
    }

    _contents.clear();
    kEvents.clear();

    _categories
      ..clear()
      ..addAll(['전체', '즐겨찾기']);
    await saveCategories();

    notifyListeners();
  }

  Future<void> toggleFavorite(ContentItem item) async {
    final deviceUuid = await getDeviceUuid();
    final newValue = !item.isFavorite;

    item.isFavorite = newValue;
    notifyListeners();

    final success = await DbService().updateFavorite(
      id: item.id,
      deviceUuid: deviceUuid,
      isFavorite: newValue,
    );

    if (!success) {
      item.isFavorite = !newValue;
      notifyListeners();
    }
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
