class PhotoModel {
  final int id;
  final String photographer;
  final String url;
  final String alt;

  PhotoModel({
    required this.id,
    required this.photographer,
    required this.url,
    required this.alt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    String extractedUrl = '';

    // 1. Check if 'src' map exists (Pexels API structure)
    if (json['src'] != null && json['src'] is Map<String, dynamic>) {
      final src = json['src'] as Map<String, dynamic>;
      extractedUrl = src['medium'] ?? src['large'] ?? src['original'] ?? '';
    }

    // 2. Check direct keys if 'src' wasn't present (Local storage format)
    if (extractedUrl.isEmpty) {
      extractedUrl = json['url'] ?? json['imageUrl'] ?? '';
    }

    return PhotoModel(
      id: json['id'] ?? 0,
      photographer: json['photographer'] ?? 'Unknown Photographer',
      url: extractedUrl,
      alt: json['alt'] ?? 'Snaply Photo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photographer': photographer,
      'url': url,
      'alt': alt,
    };
  }
}