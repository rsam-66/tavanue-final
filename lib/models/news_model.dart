class NewsItem {
  final String title;
  final String subtitle;
  final String imageRef;
  final String url;

  NewsItem({
    required this.title,
    required this.subtitle,
    required this.imageRef,
    required this.url,
  });

  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      title: map['judulBerita'] ?? '',
      subtitle: map['subJudul'] ?? '',
      imageRef: map['imageRef'] ?? '',
      url: map['url'] ?? '',
    );
  }
}
