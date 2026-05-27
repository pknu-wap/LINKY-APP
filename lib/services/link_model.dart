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
  Future<List<LinkResponse>> fetchLinksFromApi() async {
  // 1. Spring Boot 서버 API 주소
  final url = Uri.parse('${baseUrl}/api/links'); 

  try {
    // 2. 서버에 GET 요청을 보내서 데이터 가져오기 (토큰이 필요하다면 headers에 추가)
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // 3. 응답받은 JSON 문자열을 Dart의 List<dynamic> 형태로 변환
      // (서버가 [{...}, {...}] 형태의 배열을 바로 리턴한다고 가정)
      Iterable jsonList = jsonDecode(response.body);
      
      // 💡 만약 서버가 { "status": 200, "data": [...] } 형태로 리턴한다면 아래처럼 수정하세요:
      // Iterable jsonList = jsonDecode(response.body)['data'];

      // 4. 핵심 부분! map()을 이용해 JSON 맵을 LinkResponse 객체로 변환하고 리스트로 묶기
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
