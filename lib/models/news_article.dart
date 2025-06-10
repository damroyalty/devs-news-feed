import 'package:json_annotation/json_annotation.dart';

part 'news_article.g.dart';

@JsonSerializable()
class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  final String category;
  final String? author;
  final double? sentimentScore;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.category,
    this.author,
    this.sentimentScore,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleFromJson(json);

  Map<String, dynamic> toJson() => _$NewsArticleToJson(this);

  NewsArticle copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? imageUrl,
    String? source,
    DateTime? publishedAt,
    String? category,
    String? author,
    double? sentimentScore,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      author: author ?? this.author,
      sentimentScore: sentimentScore ?? this.sentimentScore,
    );
  }
}

@JsonSerializable()
class MarketData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final String type;
  final DateTime timestamp;

  const MarketData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.type,
    required this.timestamp,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) =>
      _$MarketDataFromJson(json);

  Map<String, dynamic> toJson() => _$MarketDataToJson(this);

  bool get isPositive => change >= 0;
}
