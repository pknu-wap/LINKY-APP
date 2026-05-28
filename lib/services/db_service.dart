// db_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:std/main.dart';

class DbService {
  // 베이스 URL이 있다면 상수로 관리하면 편리합니다.

  // 1. 전체 포스트 가져오기
  Future<List<PostResponse>> getAllPost() async {
    final response = await http.get(Uri.parse("$baseUrl/links"));

    if (response.statusCode == 200) {
      // response.bodyBytes를 utf8.decode 처리해주면 한글 깨짐을 방지할 수 있습니다.
      final data =
          json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

      return data
          .map<PostResponse>((json) => PostResponse.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load post list');
    }
  }

  // 2. 특정 ID의 포스트 가져오기
  Future<PostResponse> getPostById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/links/$id"));

    if (response.statusCode == 200) {
      final jsonData =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return PostResponse.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception("Post not found");
    } else {
      throw Exception("Failed to fetch Post by Id");
    }
  }
}

class PostResponse {
  final int id;
  final String url;
  final String title;
  final String category;
  final bool isPrivate;
  final DateTime selectedDate;

  PostResponse({
    required this.id,
    required this.url,
    required this.title,
    required this.category,
    required this.isPrivate,
    required this.selectedDate,
  });

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
    final url = Uri.parse('$baseUrl/api/links');

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

Future<void> deleteLink({required int id, required String deviceUuid}) async {
  print("백엔드 서버로 삭제 요청 시도 id: $id");

  // Query Parameter 형태로 URL 생성
  final Uri url = Uri.parse("$baseUrl/links/$id");

  try {
    // HTTP DELETE 요청 발송
    final response = await http.delete(
      url,
      headers: {"X-Device-UUID": deviceUuid},
    );

    if (response.statusCode == 200) {
      print("서버 삭제 완료 응답: ${response.body}");
    } else {
      print("서버 삭제 실패 상태코드: ${response.statusCode}");
      print("실패 원인: ${response.body}");
    }
  } catch (e) {
    print("네트워크 통신 에러: $e");
  }
}
