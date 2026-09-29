import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/photo_model.dart';
import '../../providers/photo_provider.dart';

class PhotoDetailScreen extends StatefulWidget {
  final PhotoModel photo;
  const PhotoDetailScreen({super.key, required this.photo});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _saveAnimController;

  @override
  void initState() {
    super.initState();
    _saveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _saveAnimController.dispose();
    super.dispose();
  }

  void _onSaveTap(PhotoProvider provider) async {
    _saveAnimController.forward().then((_) => _saveAnimController.reverse());
    await provider.toggleSavePhoto(widget.photo);
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final saved = photoProvider.isSaved(widget.photo.id);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('Check out this photo by ${widget.photo.photographer} on Snaply: ${widget.photo.url}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'photo_${widget.photo.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: widget.photo.url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(widget.photo.photographer[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.photo.photographer,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ScaleTransition(
                        scale: _saveAnimController,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: saved ? Colors.black : const Color(0xFFE60023),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => _onSaveTap(photoProvider),
                          icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                          label: Text(saved ? 'Saved' : 'Save'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.photo.alt.isNotEmpty)
                    Text(
                      widget.photo.alt,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}