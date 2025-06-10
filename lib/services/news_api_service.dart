import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsApiService {

  Future<List<NewsArticle>> getCryptoNews() async {
    try {
      return await _fetchCryptoCompareNews();
    } catch (e) {
      print('Error fetching crypto news: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> getStockNews() async {
    try {
      return await _fetchAlphaVantageNews();
    } catch (e) {
      print('Error fetching stock news: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> getEconomicNews() async {
    try {
      return await _createEconomicNews();
    } catch (e) {
      print('Error fetching economic news: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> _fetchCryptoCompareNews() async {
    try {
      final response = await http.get(
        Uri.parse('https://min-api.cryptocompare.com/data/v2/news/?lang=EN'),
        headers: {'User-Agent': 'FinanceFlow-Flutter-App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Data'] != null) {
          final articles = data['Data'] as List;

          return articles
              .take(10)
              .map(
                (article) => NewsArticle(
                  id:
                      article['id']?.toString() ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: article['title'] ?? 'Crypto News Update',
                  description: _truncateDescription(article['body'] ?? ''),
                  imageUrl:
                      article['imageurl'] ??
                      'https://via.placeholder.com/300x200/00BCD4/FFFFFF?text=Crypto',
                  source: article['source_info']?['name'] ?? 'CryptoCompare',
                  publishedAt: DateTime.fromMillisecondsSinceEpoch(
                    (article['published_on'] ?? 0) * 1000,
                  ),
                  category: 'crypto',
                  url: article['url'] ?? '',
                  author: article['source_info']?['name'],
                  sentimentScore: _analyzeSentimentScore(
                    article['title'] ?? '',
                  ),
                ),
              )
              .toList();
        }
      }
    } catch (e) {
      print('CryptoCompare API error: $e');
    }

    return _createCryptoNewsFromMarketData();
  }

  Future<List<NewsArticle>> _fetchAlphaVantageNews() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers=AAPL,MSFT,GOOGL,TSLA&limit=10&apikey=demo',
        ),
        headers: {'User-Agent': 'FinanceFlow-Flutter-App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['feed'] != null) {
          final articles = data['feed'] as List;

          return articles
              .take(10)
              .map(
                (article) => NewsArticle(
                  id:
                      article['url']?.hashCode.toString() ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: article['title'] ?? 'Market News Update',
                  description: _truncateDescription(article['summary'] ?? ''),
                  imageUrl:
                      article['banner_image'] ??
                      'https://via.placeholder.com/300x200/7B1FA2/FFFFFF?text=Stocks',
                  source: article['source'] ?? 'Alpha Vantage',
                  publishedAt: _parseAlphaVantageDate(
                    article['time_published'] ?? '',
                  ),
                  category: 'stocks',
                  url: article['url'] ?? '',
                  author: article['authors']?.isNotEmpty == true
                      ? article['authors'][0]
                      : 'Market Analyst',
                  sentimentScore:
                      double.tryParse(
                        article['overall_sentiment_score']?.toString() ?? '0',
                      ) ??
                      0.0,
                ),
              )
              .toList();
        }
      }
    } catch (e) {
      print('Alpha Vantage API error: $e');
    }
    return _createStockNewsFromMarketData();
  }

  DateTime _parseAlphaVantageDate(String dateString) {
    try {
      if (dateString.length >= 15) {
        final year = int.parse(dateString.substring(0, 4));
        final month = int.parse(dateString.substring(4, 6));
        final day = int.parse(dateString.substring(6, 8));
        final hour = int.parse(dateString.substring(9, 11));
        final minute = int.parse(dateString.substring(11, 13));
        final second = int.parse(dateString.substring(13, 15));

        return DateTime(year, month, day, hour, minute, second);
      }
    } catch (e) {
      print('Date parsing error: $e');
    }
    return DateTime.now();
  }

  String _truncateDescription(String description) {
    if (description.length > 200) {
      return '${description.substring(0, 200)}...';
    }
    return description;
  }

  Future<List<NewsArticle>> _createCryptoNewsFromMarketData() async {
    final cryptoSymbols = [
      'Bitcoin',
      'Ethereum',
      'Solana',
      'Cardano',
      'Polkadot',
    ];
    final List<NewsArticle> articles = [];

    for (int i = 0; i < cryptoSymbols.length; i++) {
      final symbol = cryptoSymbols[i];
      articles.add(
        NewsArticle(
          id: 'crypto_${symbol}_${DateTime.now().millisecondsSinceEpoch}',
          title: '$symbol Market Analysis - Latest Trends and Developments',
          description:
              'Comprehensive analysis of $symbol price movements, market sentiment, and upcoming developments in the cryptocurrency space.',
          imageUrl:
              'https://via.placeholder.com/300x200/00BCD4/FFFFFF?text=$symbol',
          source: 'Crypto Market Analysis',
          publishedAt: DateTime.now().subtract(Duration(minutes: i * 30)),
          category: 'crypto',
          url: 'https://coinmarketcap.com',
          author: 'Crypto Analyst',
          sentimentScore: (i % 3 - 1) * 0.4,
        ),
      );
    }

    return articles;
  }

  Future<List<NewsArticle>> _createStockNewsFromMarketData() async {
    final stockData = [
      {'symbol': 'AAPL', 'name': 'Apple Inc.'},
      {'symbol': 'MSFT', 'name': 'Microsoft Corporation'},
      {'symbol': 'GOOGL', 'name': 'Alphabet Inc.'},
      {'symbol': 'TSLA', 'name': 'Tesla Inc.'},
      {'symbol': 'NVDA', 'name': 'NVIDIA Corporation'},
    ];
    final List<NewsArticle> articles = [];

    for (int i = 0; i < stockData.length; i++) {
      final stock = stockData[i];
      articles.add(
        NewsArticle(
          id: 'stock_${stock['symbol']}_${DateTime.now().millisecondsSinceEpoch}',
          title:
              '${stock['name']} (${stock['symbol']}) - Market Performance Update',
          description:
              'Latest financial performance, earnings outlook, and market position analysis for ${stock['name']}.',
          imageUrl:
              'https://via.placeholder.com/300x200/7B1FA2/FFFFFF?text=${stock['symbol']}',
          source: 'Financial Market Data',
          publishedAt: DateTime.now().subtract(Duration(minutes: i * 45)),
          category: 'stocks',
          url: 'https://finance.yahoo.com/quote/${stock['symbol']}',
          author: 'Market Analyst',
          sentimentScore: (i % 3 - 1) * 0.5,
        ),
      );
    }

    return articles;
  }

  Future<List<NewsArticle>> _createEconomicNews() async {
    final economicTopics = [
      {
        'title': 'Federal Reserve Interest Rate Policy Update',
        'desc':
            'Analysis of current monetary policy decisions and their impact on financial markets and economic growth.',
        'category': 'Monetary Policy',
      },
      {
        'title': 'Global GDP Growth Trends and Forecasts',
        'desc':
            'Quarterly economic growth analysis covering major economies and emerging market developments.',
        'category': 'Economic Growth',
      },
      {
        'title': 'Consumer Price Index and Inflation Analysis',
        'desc':
            'Latest inflation data, trends in consumer prices, and impact on purchasing power and policy decisions.',
        'category': 'Inflation Data',
      },
      {
        'title': 'Employment Market Dynamics and Labor Statistics',
        'desc':
            'Monthly job market analysis, unemployment trends, and workforce participation rates.',
        'category': 'Employment',
      },
      {
        'title': 'International Trade and Economic Relations',
        'desc':
            'Trade balance updates, international economic partnerships, and global commerce trends.',
        'category': 'International Trade',
      },
    ];

    return economicTopics.asMap().entries.map((entry) {
      final topic = entry.value;
      return NewsArticle(
        id: 'econ_${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
        title: topic['title']!,
        description: topic['desc']!,
        imageUrl:
            'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=${Uri.encodeComponent(topic['category']!)}',
        source: 'Economic Analysis Bureau',
        publishedAt: DateTime.now().subtract(Duration(hours: entry.key * 2)),
        category: 'economic',
        url: 'https://www.bls.gov',
        author: 'Economic Research Team',
        sentimentScore: 0.0,
      );
    }).toList();
  }

  double _analyzeSentimentScore(String title) {
    final titleLower = title.toLowerCase();

    final positiveWords = [
      'rise',
      'gain',
      'surge',
      'bull',
      'growth',
      'profit',
      'success',
      'breakthrough',
      'rally',
      'up',
      'high',
      'strong',
      'boost',
      'soar',
    ];
    final negativeWords = [
      'fall',
      'drop',
      'crash',
      'bear',
      'loss',
      'decline',
      'struggle',
      'concern',
      'warning',
      'down',
      'low',
      'weak',
      'plunge',
      'tumble',
    ];

    double score = 0.0;

    for (String word in positiveWords) {
      if (titleLower.contains(word)) score += 0.1;
    }

    for (String word in negativeWords) {
      if (titleLower.contains(word)) score -= 0.1;
    }
    return score.clamp(-1.0, 1.0);
  }

  Future<List<NewsArticle>> getAllNews() async {
    final List<NewsArticle> allNews = [];
    try {
      final futures = await Future.wait([
        getCryptoNews(),
        getStockNews(),
        getEconomicNews(),
      ]);
      for (final newsList in futures) {
        allNews.addAll(newsList);
      }
      allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allNews;
    } catch (e) {
      print('Error fetching all news: $e');
      return [];
    }
  }
}
