import 'package:flutter/material.dart';
import 'package:std/pages/calender_page.dart';
import 'package:std/services/data_service.dart';

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

  List<String> get categories => _categories;
  List<ContentItem> get contents => _contents;

  Future<void> loadContentsFromDb(String kakaoId) async {
    final rows = await _dataService.fetchLinksByKakaoId(kakaoId);

    _contents.clear();

    for (final row in rows) {
      _contents.add(
        ContentItem(
          id: int.parse(row['id'].toString()),
          title: row['title'] ?? '',
          url: row['url'] ?? '',
          category: row['category'] ?? '전체',
          isPrivate: row['is_private'].toString() == '1',
          time: row['selected_date']?.toString(),
        ),
      );
    }

    notifyListeners();
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

  // contents 관리 로직

  int addContent({
    required int id,
    required String title,
    required String url,
    required bool isPrivate,
    required String? datetime,
    String category = '전체',
  }) {
    final verifiedCategory = _categories.contains(category) ? category : '전체';

    final newItem = ContentItem(
      id: id,
      title: title,
      url: url,
      isPrivate: isPrivate,
      time: datetime,

      category: verifiedCategory,
    );
    _contents.add(newItem);
    notifyListeners();

    return id;
  }

  Future<void> removeContent({required int id, required String kakaoId}) async {
    await _dataService.deleteLink(id: id, kakaoId: kakaoId);

    _contents.removeWhere((item) => item.id == id);

    kEvents.forEach((date, eventList) {
      eventList.removeWhere((event) => event.contentID == id);
    });

    kEvents.removeWhere((date, eventList) => eventList.isEmpty);

    notifyListeners();
  }

  void updateContent({
    required int id,
    required String newTitle,
    required String newUrl,
    required String? newTime,
    String? newCategory,
  }) {
    int index = _contents.indexWhere((item) => item.id == id);

    if (index != -1) {
      String? oldTimeStr = _contents[index].time;

      _contents[index].title = newTitle;
      _contents[index].url = newUrl;
      _contents[index].time = newTime;

      if (newCategory != null) {
        _contents[index].category = _categories.contains(newCategory)
            ? newCategory
            : '전체';
      }

      if (oldTimeStr != null) {
        DateTime oldDate = DateTime.parse(oldTimeStr);
        DateTime oldDateKey = DateTime.utc(
          oldDate.year,
          oldDate.month,
          oldDate.day,
        );

        if (kEvents.containsKey(oldDateKey)) {
          kEvents[oldDateKey]!.removeWhere((event) => event.contentID == id);
          if (kEvents[oldDateKey]!.isEmpty) kEvents.remove(oldDateKey);
        }
      }

      // 3. 새로운 이벤트 등록 (newTime이 있을 경우에만)
      if (newTime != null) {
        DateTime newDate = DateTime.parse(newTime);
        DateTime newDateKey = DateTime.utc(
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
    return kEvents[day] ?? [];
  }

  void removeEvent(DateTime day, int contentID) {
    final dateOnly = DateTime.utc(day.year, day.month, day.day);

    if (kEvents.containsKey(dateOnly)) {
      // 1. 전역 변수 kEvents에서 해당 contentID를 가진 이벤트만 찾아서 삭제 (안전한 방식)
      kEvents[dateOnly]!.removeWhere((event) => event.contentID == contentID);

      // 만약 해당 날짜에 데이터가 없으면 키 삭제
      if (kEvents[dateOnly]!.isEmpty) {
        kEvents.remove(dateOnly);
      }
    }

    // 2. 아예 삭제하지 않고, contents 리스트에서 해당 아이템의 time만 null로 변경!
    int index = _contents.indexWhere((item) => item.id == contentID);
    if (index != -1) {
      _contents[index].time = null;
    }

    notifyListeners();
  }
}
