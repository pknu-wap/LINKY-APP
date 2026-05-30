// db_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:std/main.dart';

class DbService {
  Future<List<PostResponse>> getAllPost() async {
    final response = await http.get(Uri.parse("$baseUrl/links"));

    if (response.statusCode == 200) {
      final data =
          json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

      return data
          .map<PostResponse>((json) => PostResponse.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load post list');
    }
  }

  Future<bool> updateFavorite({
    required int id,
    required String deviceUuid,
    required bool isFavorite,
  }) async{
    final response = await http.patch(
      Uri.parse("$baseUrl/links/$id"),
      headers: {
        "Content-Type": "application/json",
        "X-Device-UUID": deviceUuid,
      },
      body: json.encode({
        "isFavorite": isFavorite,
      }),
    );
    return response.statusCode == 200;
  }

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

  Future<bool> resetData({required String deviceUuid}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/links/reset'),
        headers: {
          'X-Device-UUID': deviceUuid,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("초기화 통신 에러: $e");
      return false;
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
  final bool isFavorite;

  PostResponse({
    required this.id,
    required this.url,
    required this.title,
    required this.category,
    required this.isPrivate,
    required this.selectedDate,
    required this.isFavorite,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      isPrivate: json['isPrivate'] as bool,
      selectedDate: DateTime.parse(json['selectedDate'] as String),
      isFavorite: json['isFavorite'] as bool,
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
  final bool isFavorite;

  LinkResponse({
    required this.id,
    required this.url,
    this.title,
    this.category,
    required this.isPrivate,
    this.summary,
    this.selectedDate,
    required this.isFavorite,
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
      isFavorite: json['isFavorite'] ?? false,
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

Future<void> deleteLink({required int id, required String deviceUuid}) async {
  print("백엔드 서버로 삭제 요청 시도 id: $id");

  final Uri url = Uri.parse("$baseUrl/links/$id");

  try {
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
