part of 'news_article.dart';

NewsArticle _$NewsArticleFromJson(Map<String, dynamic> json) => NewsArticle(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  url: json['url'] as String,
  imageUrl: json['imageUrl'] as String?,
  source: json['source'] as String,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  category: json['category'] as String,
  author: json['author'] as String?,
  sentimentScore: (json['sentimentScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$NewsArticleToJson(NewsArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
      'source': instance.source,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'category': instance.category,
      'author': instance.author,
      'sentimentScore': instance.sentimentScore,
    };

MarketData _$MarketDataFromJson(Map<String, dynamic> json) => MarketData(
  symbol: json['symbol'] as String,
  price: (json['price'] as num).toDouble(),
  change: (json['change'] as num).toDouble(),
  changePercent: (json['changePercent'] as num).toDouble(),
  type: json['type'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$MarketDataToJson(MarketData instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'price': instance.price,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'type': instance.type,
      'timestamp': instance.timestamp.toIso8601String(),
    };
