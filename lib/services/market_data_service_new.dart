import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class MarketDataService {
  static final MarketDataService _instance = MarketDataService._internal();
  factory MarketDataService() => _instance;
  MarketDataService._internal();

  final Map<String, double> _currentPrices = {};
  final Map<String, double> _changePercentages = {};

  Timer? _priceUpdateTimer;

  void startRealTimeUpdates() {
    _fetchRealPrices();

    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchRealPrices();
    });
  }

  void stopRealTimeUpdates() {
    _priceUpdateTimer?.cancel();
  }

  Future<void> _fetchRealPrices() async {
    try {
      await _fetchCryptoPrices();

      await _fetchStockPrices();
    } catch (e) {
      print('Error fetching real prices: $e');
      _useFallbackPrices();
    }
  }

  Future<void> _fetchCryptoPrices() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,cardano,polkadot,avalanche-2,polygon,chainlink&vs_currencies=usd&include_24hr_change=true',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final cryptoMapping = {
          'bitcoin': 'BTC',
          'ethereum': 'ETH',
          'solana': 'SOL',
          'cardano': 'ADA',
          'polkadot': 'DOT',
          'avalanche-2': 'AVAX',
          'polygon': 'MATIC',
          'chainlink': 'LINK',
        };

        cryptoMapping.forEach((coinId, symbol) {
          if (data[coinId] != null) {
            _currentPrices[symbol] = data[coinId]['usd'].toDouble();
            _changePercentages[symbol] =
                data[coinId]['usd_24h_change']?.toDouble() ?? 0.0;
          }
        });

        print('✅ Crypto prices updated from CoinGecko API');
      }
    } catch (e) {
      print('Error fetching crypto prices: $e');
    }
  }

  Future<void> _fetchStockPrices() async {
    try {
      final symbols = [
        'AAPL',
        'MSFT',
        'GOOGL',
        'TSLA',
        'NVDA',
        'AMZN',
        'META',
        'NFLX',
      ];

      for (String symbol in symbols) {
        try {
          final response = await http.get(
            Uri.parse(
              'https://query1.finance.yahoo.com/v8/finance/chart/$symbol',
            ),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final result = data['chart']['result'][0];
            final meta = result['meta'];

            final currentPrice = meta['regularMarketPrice']?.toDouble();
            final previousClose = meta['previousClose']?.toDouble();

            if (currentPrice != null && previousClose != null) {
              _currentPrices[symbol] = currentPrice;
              final changePercent =
                  ((currentPrice - previousClose) / previousClose) * 100;
              _changePercentages[symbol] = changePercent;
            }
          }
        } catch (e) {
          print('Error fetching $symbol: $e');
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }

      print('✅ Stock prices updated from Yahoo Finance API');
    } catch (e) {
      print('Error fetching stock prices: $e');
    }
  }

  void _useFallbackPrices() {
    final fallbackPrices = {
      'BTC': 67250.0,
      'ETH': 3825.0,
      'SOL': 182.5,
      'ADA': 0.48,
      'DOT': 7.2,
      'AVAX': 38.5,
      'MATIC': 0.72,
      'LINK': 15.8,
      'AAPL': 193.5,
      'MSFT': 425.8,
      'GOOGL': 175.2,
      'TSLA': 248.9,
      'NVDA': 1208.5,
      'AMZN': 186.7,
      'META': 511.2,
      'NFLX': 684.3,
    };

    _currentPrices.addAll(fallbackPrices);

    final random = Random();
    fallbackPrices.keys.forEach((symbol) {
      _changePercentages[symbol] =
          (random.nextDouble() - 0.5) * 4;
    });

    print('⚠️ Using fallback prices - API connection failed');
  }

  List<MarketData> getCryptoData() {
    return [
      _createMarketData('BTC', 'crypto'),
      _createMarketData('ETH', 'crypto'),
      _createMarketData('SOL', 'crypto'),
      _createMarketData('ADA', 'crypto'),
      _createMarketData('DOT', 'crypto'),
      _createMarketData('AVAX', 'crypto'),
      _createMarketData('MATIC', 'crypto'),
      _createMarketData('LINK', 'crypto'),
    ];
  }

  List<MarketData> getStockData() {
    return [
      _createMarketData('AAPL', 'stock'),
      _createMarketData('MSFT', 'stock'),
      _createMarketData('GOOGL', 'stock'),
      _createMarketData('TSLA', 'stock'),
      _createMarketData('NVDA', 'stock'),
      _createMarketData('AMZN', 'stock'),
      _createMarketData('META', 'stock'),
      _createMarketData('NFLX', 'stock'),
    ];
  }

  MarketData _createMarketData(String symbol, String type) {
    final currentPrice = _currentPrices[symbol] ?? 0.0;
    final changePercent = _changePercentages[symbol] ?? 0.0;

    return MarketData(
      symbol: symbol,
      price: currentPrice,
      changePercent: changePercent,
      type: type,
    );
  }

  List<MarketData> getAllMarketData() {
    return [...getCryptoData(), ...getStockData()];
  }
}
