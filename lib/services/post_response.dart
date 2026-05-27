
class PostResponse {
  final int id;
  final String url;
  final String title;
  final String category;
  final bool isPrivate;
  final DateTime selectedDate;

  PostResponse({required this.id, required this.url, required this.title, required this.category, required this.isPrivate, required this.selectedDate});

  // JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      isPrivate: json['isPrivate'] as bool,
      selectedDate: DateTime.parse(json['selectedDate'] as String),
    );
  }
}