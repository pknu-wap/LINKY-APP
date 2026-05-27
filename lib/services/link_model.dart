class LinkResponse {
  final int id;
  final String url;
  final String? title;
  final String? category;
  final bool isPrivate;
  final String? summary;
  final String? selectedDate;

  LinkResponse({
    required this.id,
    required this.url,
    this.title,
    this.category,
    required this.isPrivate,
    this.summary,
    this.selectedDate,
  });

  // 서버에서 준 JSON 데이터를 Dart 객체로 변환하는 팩토리 메서드
  factory LinkResponse.fromJson(Map<String, dynamic> json) {
    return LinkResponse(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      category: json['category'],
      isPrivate: json['isPrivate'] ?? false,
      summary: json['summary'],
      selectedDate: json['selectedDate'] ?? json['selected_date'],
    );
  }
}