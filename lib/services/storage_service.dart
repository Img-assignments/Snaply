import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo_model.dart';

class StorageService {
  static String _getKey(String userId) => 'saved_photos_$userId';

  Future<List<PhotoModel>> getSavedPhotos(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_getKey(userId));
    if (rawData == null) return [];

    try {
      final List decoded = jsonDecode(rawData);
      return decoded
          .map((item) => PhotoModel.fromJson(item))
      // Safety check: Filter out any items with missing or invalid URLs
          .where((photo) => photo.url.isNotEmpty && photo.url.startsWith('http'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePhotos(String userId, List<PhotoModel> photos) async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = jsonEncode(photos.map((p) => p.toJson()).toList());
    await prefs.setString(_getKey(userId), rawData);
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_mode', mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_theme_mode') ?? 'system';
  }
}