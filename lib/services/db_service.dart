// db_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:std/services/post_response.dart';
import 'package:std/main.dart';



class DbService {
  // 베이스 URL이 있다면 상수로 관리하면 편리합니다.

  // 1. 전체 포스트 가져오기
  Future<List<PostResponse>> getAllPost() async {
    final response = await http.get(Uri.parse("$baseUrl/links"));
    
    if (response.statusCode == 200) {
      // response.bodyBytes를 utf8.decode 처리해주면 한글 깨짐을 방지할 수 있습니다.
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      
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
      final jsonData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return PostResponse.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception("Post not found");
    } else {
      throw Exception("Failed to fetch Post by Id");
    }
  }
}