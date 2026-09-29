import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/photo_provider.dart';
import '../detail/photo_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final photoProvider = Provider.of<PhotoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search for photos (e.g. nature, cars)...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                photoProvider.onSearchQueryChanged('');
                setState(() {});
              },
            )
                : null,
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {});
            photoProvider.onSearchQueryChanged(val);
          },
        ),
      ),
      body: _buildSearchResults(photoProvider),
    );
  }

  Widget _buildSearchResults(PhotoProvider provider) {
    if (provider.isLoadingSearch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Search failed:\n${provider.searchError}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => provider.onSearchQueryChanged(_searchController.text),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return const Center(child: Text('Type something to search photos.'));
    }

    if (provider.searchPhotos.isEmpty) {
      return const Center(child: Text('No results found for your search.'));
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: provider.searchPhotos.length,
      itemBuilder: (context, index) {
        final photo = provider.searchPhotos[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}