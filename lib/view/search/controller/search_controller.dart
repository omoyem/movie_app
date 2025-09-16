import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:godly_seed_app/data/models/movie_list_response.dart';
import 'package:godly_seed_app/data/models/search.dart';
import 'package:godly_seed_app/network/api_client.dart';
import 'package:godly_seed_app/utils/helpers.dart';
class SearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<SearchResult> searchResults = <SearchResult>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  ApiClient apiClient = ApiClient(appbaseurl: Endpoints.baseUrl);
  LocalStorageHelper _storageHelper = LocalStorageHelper();

  Timer? _debounceTimer;
  final int _debounceMilliseconds = 500;


  final List<String> availableTags = [
    'Documentary',
    'Animation',
    'Educational',
    'Biblical',
    'Musical',
    'Kids',
    'Family',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounceTimer?.cancel();
    
    if (value.isEmpty) {
      searchResults.clear();
      errorMessage.value = '';
      return;
    }

    _debounceTimer = Timer(Duration(milliseconds: _debounceMilliseconds), () {
      performSearch(value);
    });
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      _addToRecentSearches(query.trim());

      final Map<String, dynamic> requestBody = {
        'q': query.trim(),
      };

      if (selectedTags.isNotEmpty) {
        requestBody['tags'] = selectedTags.join(',');
      }

      logItem(requestBody, title: "Search request body");

 
      final response = await apiClient.postRequest(
        url: Endpoints.searchMovies, 
        data: requestBody,
      );

      logItem(response.body, title: "Search response body");

      if (response.statusCode == 200) {
        final searchResponse = SearchResponse.fromJson(json.decode(response.body));
        
        if (searchResponse.responseCode == 200) {
          searchResults.value = searchResponse.data;
        } else {
          throw Exception(searchResponse.responseMessage);
        }
      } else {
        throw Exception('${response.statusCode}');
      }
    } catch (e) {
      logItem(e.toString(), title: " ");
      errorMessage.value = '';
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void searchFromRecent(String query) {
    searchController.text = query;
    searchQuery.value = query;
    performSearch(query);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    selectedTags.clear();
    errorMessage.value = '';
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    
    if (searchQuery.value.isNotEmpty) {
      performSearch(searchQuery.value);
    }
  }

  void navigateToMovieDetails(SearchResult searchResult) {
    
    Movies movie = searchResult.toMovies();
    Get.toNamed(AppRouter.movie, arguments: movie);
  }

  void _addToRecentSearches(String query) {
  
    recentSearches.remove(query);
    
  
    recentSearches.insert(0, query);
 
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    

    _saveRecentSearches();
  }

  void removeRecentSearch(String query) {
    recentSearches.remove(query);
    _saveRecentSearches();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  void _loadRecentSearches() {
    
  }

  void _saveRecentSearches() {
    
  }

  void handleApiError(String error) {
    errorMessage.value = error;
    Get.snackbar(
      'Search Error',
      error,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void clearError() {
    errorMessage.value = '';
  }
}