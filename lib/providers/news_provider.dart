import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/news_article.dart';
import '../services/news_api_service.dart';
import '../services/market_data_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApiService _newsService = NewsApiService();
  final MarketDataService _marketService = MarketDataService();

  List<NewsArticle> _allNews = [];
  List<NewsArticle> _filteredNews = [];
  List<MarketData> _marketData = [];

  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = 'all';
  Timer? _marketUpdateTimer;

  List<NewsArticle> get allNews => _allNews;
  List<NewsArticle> get filteredNews => _filteredNews;
  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;

  final List<String> categories = ['all', 'stocks', 'crypto', 'economic'];

  NewsProvider() {
    loadInitialData();
    _startRealTimeMarketUpdates();
  }

  @override
  void dispose() {
    _marketUpdateTimer?.cancel();
    _marketService.stopRealTimeUpdates();
    super.dispose();
  }

  void _startRealTimeMarketUpdates() {
    _marketService.startRealTimeUpdates();
    _marketUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchMarketData();
    });
  }

  Future<void> loadInitialData() async {
    await fetchAllNews();
    await fetchMarketData();
  }

  Future<void> fetchAllNews() async {
    _setLoading(true);
    _error = '';

    try {
      _allNews = await _newsService.getAllNews();
      _filterNews();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load news: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMarketData() async {
    try {
      _marketData = await _marketService.getAllMarketData();
      notifyListeners();
    } catch (e) {
      print('Error fetching market data: $e');
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _filterNews();
      notifyListeners();
    }
  }

  void _filterNews() {
    if (_selectedCategory == 'all') {
      _filteredNews = List.from(_allNews);
    } else {
      _filteredNews = _allNews
          .where((article) => article.category == _selectedCategory)
          .toList();
    }
  }

  Future<void> refreshNews() async {
    await fetchAllNews();
    await fetchMarketData();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<NewsArticle> getNewsByCategory(String category) {
    return _allNews.where((article) => article.category == category).toList();
  }

  List<MarketData> getCryptoData() {
    return _marketData.where((data) => data.type == 'crypto').toList();
  }

  List<MarketData> getStockData() {
    return _marketData.where((data) => data.type == 'stock').toList();
  }
}
