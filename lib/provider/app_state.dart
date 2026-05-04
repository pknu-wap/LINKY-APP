import 'package:flutter/material.dart';
import 'package:std/pages/calender_page.dart';

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

  final List<ContentItem> _contents = [
    // 초기 더미 데이터 (나중에 DB 연동 시 fetch함수로 대체)
    ContentItem(
      id: 1,
      title: "Google",
      url: "https://google.com",
      isPrivate: true,
      time: null,
    ),
    ContentItem(
      id: 2,
      title: "Flutter",
      url: "https://flutter.dev",
      isPrivate: true,
      time: null,
    ),
  ];

  List<String> get categories => _categories;
  List<ContentItem> get contents => _contents;
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
    required String title,
    required String url,
    required bool isPrivate,
    required String? datetime,
    String category = '전체',
  }) {
    final verifiedCategory = _categories.contains(category) ? category : '전체';

    final newID = _contents.length + 1;

    final newItem = ContentItem(
      id: newID,
      title: title,
      url: url,
      isPrivate: isPrivate,
      time: datetime,

      category: verifiedCategory,
    );
    _contents.add(newItem);
    notifyListeners();

    return newID;
  }

  void removeContent(int id) {
    _contents.removeWhere((item) => item.id == id);
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
      _contents[index].title = newTitle;
      _contents[index].url = newUrl;
      _contents[index].time = newTime;

      if (newCategory != null) {
        _contents[index].category = _categories.contains(newCategory)
            ? newCategory
            : '전체';
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
