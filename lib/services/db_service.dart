// db_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:std/services/post_response.dart';
import 'package:std/main.dart';



class DbService {
  Future<List<PostResponse>> getAllPost() async {
    final response = await http.get(Uri.parse("$baseUrl/links"));
    
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      
      return data
          .map<PostResponse>((json) => PostResponse.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load post list');
    }
  }

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