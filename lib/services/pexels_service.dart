import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/photo_model.dart';
import '../config/api_keys.dart';

class PexelsService {
  static const String _apiKey = ApiKeys.pexelsApiKey;
  static const String _baseUrl = 'https://api.pexels.com/v1';

  Future<List<PhotoModel>> fetchCuratedPhotos({int page = 1, int perPage = 20}) async {
    final url = Uri.parse('$_baseUrl/curated?page=$page&per_page=$perPage');

    final response = await http.get(
      url,
      headers: {'Authorization': _apiKey},
    );

    

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List photosJson = data['photos'] ?? [];
      return photosJson.map((json) => PhotoModel.fromJson(json)).toList();
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<PhotoModel>> searchPhotos(String query, {int page = 1, int perPage = 20}) async {
    final url = Uri.parse('$_baseUrl/search?query=${Uri.encodeComponent(query)}&page=$page&per_page=$perPage');

    final response = await http.get(
      url,
      headers: {'Authorization': _apiKey},
    );

    debugPrint('Pexels Search Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List photosJson = data['photos'] ?? [];
      return photosJson.map((json) => PhotoModel.fromJson(json)).toList();
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}