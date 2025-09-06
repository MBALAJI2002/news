class Article {
  // Core identifiers and classification
  final String id;                 // e.g. "football/live/2025/aug/31/..."
  final String type;               // e.g. "liveblog"

  // Section metadata
  final String sectionId;          // e.g. "football"
  final String sectionName;        // e.g. "Football"

  // Publication & links
  final DateTime webPublicationDate; // parsed from ISO string
  final String webTitle;             // e.g. "Rangers v Celtic: ..."
  final String webUrl;               // canonical public URL
  final String apiUrl;               // Guardian API URL for this item

  // Hosting & pillar (high-level taxonomy)
  final bool isHosted;             // e.g. false
  final String? pillarId;          // e.g. "pillar/sport" (nullable)
  final String? pillarName;        // e.g. "Sport" (nullable)

  const Article({
    required this.id,
    required this.type,
    required this.sectionId,
    required this.sectionName,
    required this.webPublicationDate,
    required this.webTitle,
    required this.webUrl,
    required this.apiUrl,
    required this.isHosted,
    this.pillarId,
    this.pillarName,
  });

  /// Build from a single item in `response.results` from the Guardian Content API.
  factory Article.fromGuardian(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      type: (json['type'] as String?) ?? '',
      sectionId: (json['sectionId'] as String?) ?? '',
      sectionName: (json['sectionName'] as String?) ?? '',
      webPublicationDate: DateTime.parse(json['webPublicationDate'] as String),
      webTitle: (json['webTitle'] as String?) ?? '',
      webUrl: (json['webUrl'] as String?) ?? '',
      apiUrl: (json['apiUrl'] as String?) ?? '',
      isHosted: (json['isHosted'] as bool?) ?? false,
      pillarId: json['pillarId'] as String?,
      pillarName: json['pillarName'] as String?,
    );
  }

  /// Optional convenience getters (useful in UI/logic).
  bool get isLiveBlog => type.toLowerCase() == 'liveblog';
}
