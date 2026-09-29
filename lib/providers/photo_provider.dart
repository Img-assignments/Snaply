import 'dart:async';
import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../services/pexels_service.dart';
import '../services/storage_service.dart';

class PhotoProvider with ChangeNotifier {
  final PexelsService _pexelsService = PexelsService();
  final StorageService _storageService = StorageService();

  // Home Feed State
  List<PhotoModel> _homePhotos = [];
  bool _isLoadingHome = false;
  bool _isFetchingMoreHome = false;
  String? _homeError;
  int _homePage = 1;

  // Search State
  List<PhotoModel> _searchPhotos = [];
  bool _isLoadingSearch = false;
  String? _searchError;
  Timer? _debounceTimer;

  // Saved Photos State
  List<PhotoModel> _savedPhotos = [];
  String? _currentUserId;

  List<PhotoModel> get homePhotos => _homePhotos;
  bool get isLoadingHome => _isLoadingHome;
  bool get isFetchingMoreHome => _isFetchingMoreHome;
  String? get homeError => _homeError;

  List<PhotoModel> get searchPhotos => _searchPhotos;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get searchError => _searchError;

  List<PhotoModel> get savedPhotos => _savedPhotos;

  void updateUser(String? userId) {
    _currentUserId = userId;
    if (userId != null) {
      _loadSavedPhotos();
    } else {
      _savedPhotos = [];
      notifyListeners();
    }
  }

  // --- Home Feed Actions ---
  Future<void> fetchHomePhotos({bool refresh = false}) async {
    if (refresh) {
      _homePage = 1;
      _homePhotos.clear();
    }

    if (_homePage == 1) {
      _isLoadingHome = true;
      _homeError = null;
      notifyListeners();
    } else {
      _isFetchingMoreHome = true;
      notifyListeners();
    }

    try {
      final newPhotos = await _pexelsService.fetchCuratedPhotos(page: _homePage);
      if (refresh) {
        _homePhotos = newPhotos;
      } else {
        _homePhotos.addAll(newPhotos);
      }
      _homePage++;
      _homeError = null;
    } catch (e) {
      _homeError = e.toString();
    } finally {
      _isLoadingHome = false;
      _isFetchingMoreHome = false;
      notifyListeners();
    }
  }

  // --- Search Actions (Debounced) ---
  void onSearchQueryChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.trim().isEmpty) {
      _searchPhotos = [];
      _isLoadingSearch = false;
      _searchError = null;
      notifyListeners();
      return;
    }

    // Debounce for 600ms before sending API call
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    _isLoadingSearch = true;
    _searchError = null;
    notifyListeners();

    try {
      final results = await _pexelsService.searchPhotos(query);
      _searchPhotos = results;
    } catch (e) {
      _searchError = e.toString();
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }

  // --- Saved Item Actions ---
  bool isSaved(int photoId) {
    return _savedPhotos.any((p) => p.id == photoId);
  }

  Future<void> toggleSavePhoto(PhotoModel photo) async {
    if (_currentUserId == null) return;

    final exists = isSaved(photo.id);
    if (exists) {
      _savedPhotos.removeWhere((p) => p.id == photo.id);
    } else {
      _savedPhotos.add(photo);
    }
    notifyListeners(); // Updates all screens instantaneously
    await _storageService.savePhotos(_currentUserId!, _savedPhotos);
  }

  Future<void> _loadSavedPhotos() async {
    if (_currentUserId == null) return;
    _savedPhotos = await _storageService.getSavedPhotos(_currentUserId!);
    notifyListeners();
  }
}