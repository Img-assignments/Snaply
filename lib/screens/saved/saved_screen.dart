import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/photo_provider.dart';
import '../detail/photo_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final photoProvider = Provider.of<PhotoProvider>(context);
    final savedPhotos = photoProvider.savedPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Ideas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: savedPhotos.isEmpty
          ? const Center(
        child: Text('No saved items yet.'),
      )
          : MasonryGridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: savedPhotos.length,
        itemBuilder: (context, index) {
          final photo = savedPhotos[index];

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PhotoDetailScreen(
                    photo: photo,
                  ),
                ),
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
      ),
    );
  }
}