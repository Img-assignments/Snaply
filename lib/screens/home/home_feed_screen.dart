import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/photo_provider.dart';
import '../detail/photo_detail_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PhotoProvider>(context, listen: false);
      if (provider.homePhotos.isEmpty) {
        provider.fetchHomePhotos();
      }
    });

    // Infinite Scroll Trigger
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        final provider = Provider.of<PhotoProvider>(context, listen: false);
        if (!provider.isFetchingMoreHome && !provider.isLoadingHome) {
          provider.fetchHomePhotos();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final photoProvider = Provider.of<PhotoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Round Logo
            ClipOval(
              child: Image.asset(
                'assets/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 230),
            // App Name
            const Text(
              'Snaply',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => photoProvider.fetchHomePhotos(refresh: true),
        child: _buildBody(photoProvider),
      ),
    );
  }

  Widget _buildBody(PhotoProvider provider) {
    if (provider.isLoadingHome && provider.homePhotos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.homeError != null && provider.homePhotos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading photos:\n${provider.homeError}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => provider.fetchHomePhotos(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.homePhotos.isEmpty) {
      return const Center(child: Text('No photos found.'));
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childCount: provider.homePhotos.length,
            itemBuilder: (context, index) {
              final photo = provider.homePhotos[index];
              return Hero(
                tag: 'photo_${photo.id}',
                child: GestureDetector(
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
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (provider.isFetchingMoreHome)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}