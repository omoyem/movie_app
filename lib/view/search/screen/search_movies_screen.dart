
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:movie_app/constants/color_palette.dart';
import 'package:movie_app/constants/endpoints.dart';
import 'package:movie_app/data/models/movie_list_response.dart';
import 'package:movie_app/data/models/search.dart';
import 'package:movie_app/view/search/controller/search_controller.dart';
import 'package:movie_app/view/widgets/custom_container_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchMoviesScreen extends GetView<SearchController> {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SearchController>()) {
      Get.put(SearchController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            // _buildFilterTags(),
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          onSubmitted: controller.performSearch,
          decoration: InputDecoration(
            hintText: 'Search for movies, documentaries...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: controller.clearSearch,
                  )
                : SizedBox.shrink()),
          ),
          autofocus: true,
        ),
      ),
    );
  }

  // Widget _buildFilterTags() {
  //   return Obx(() => controller.searchQuery.value.isNotEmpty
  //       ? Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: Row(
  //               children: controller.availableTags.map((tag) {
  //                 return Padding(
  //                   padding: const EdgeInsets.only(right: 8.0),
  //                   child: FilterChip(
  //                     label: Text(tag),
  //                     selected: controller.selectedTags.contains(tag),
  //                     onSelected: (selected) {
  //                       controller.toggleTag(tag);
  //                     },
  //                     selectedColor: primaryColor.withOpacity(0.2),
  //                     checkmarkColor: primaryColor,
  //                   ),
  //                 );
  //               }).toList(),
  //             ),
  //           ),
  //         )
  //       : SizedBox.shrink());
  // }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.searchQuery.value.isEmpty) {
        return _buildRecentSearches();
      }

      if (controller.isLoading.value) {
        return _buildLoadingGrid();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }

      if (controller.searchResults.isEmpty) {
        return _buildNoResults();
      }

      return _buildResultsGrid();
    });
  }

  Widget _buildRecentSearches() {
    return Obx(() => controller.recentSearches.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearRecentSearches,
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.recentSearches.length,
                  itemBuilder: (context, index) {
                    final search = controller.recentSearches[index];
                    return ListTile(
                      leading: Icon(Icons.history, color: Colors.grey),
                      title: Text(search),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => controller.removeRecentSearch(search),
                      ),
                      onTap: () => controller.searchFromRecent(search),
                    );
                  },
                ),
              ),
            ],
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Search for movies and documentaries',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ));
  }

  Widget _buildLoadingGrid() {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildMovieCard(null);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            controller.errorMessage.value,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.performSearch(controller.searchQuery.value),
            child: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${controller.searchResults.length} results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final movie = controller.searchResults[index];
              return _buildMovieCard(movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(SearchResult? movie) {
    return GestureDetector(
      onTap: () {
        if (movie != null) {
          controller.navigateToMovieDetails(movie);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: movie == null ? Colors.grey[300] : null,
                        image: movie?.coverPhotoPath != null && movie!.coverPhotoPath!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  Endpoints.imageBaseUrl + movie.coverPhotoPath!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: movie?.coverPhotoPath == null || movie!.coverPhotoPath!.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movie?.duration ?? '0m',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie?.title ?? 'Movie Title',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      movie?.description ?? 'Movie description',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}