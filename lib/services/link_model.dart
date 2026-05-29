import 'package:std/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Future<List<LinkResponse>> fetchLinksFromApi() async {
  final url = Uri.parse('$baseUrl/api/links'); 

  try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Iterable jsonList = jsonDecode(response.body);
      return jsonList.map((json) => LinkResponse.fromJson(json)).toList();
      
    } else {
      throw Exception('서버 응답 오류: 상태 코드 ${response.statusCode}');
    }
  } catch (e) {
    print('데이터 통신 에러: $e');
    throw Exception('데이터를 가져오는데 실패했습니다.');
  }
}
}
