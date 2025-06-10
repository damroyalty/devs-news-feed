import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/news_article.dart';
import '../theme/app_theme.dart';

class MarketTicker extends StatefulWidget {
  final List<MarketData> marketData;

  const MarketTicker({super.key, required this.marketData});

  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scrollAnimation;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        seconds: 300,
      ),
      vsync: this,
    )..repeat();

    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _scrollAnimation.addListener(() {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final currentScroll = (maxScrollExtent * 0.25) * _scrollAnimation.value;
        _scrollController.jumpTo(currentScroll);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.marketData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.surfaceDark.withOpacity(0.8),
            AppTheme.cardDark.withOpacity(0.9),
            AppTheme.surfaceDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              widget.marketData.length *
              5,
          itemBuilder: (context, index) {
            final dataIndex = index % widget.marketData.length;
            final data = widget.marketData[dataIndex];
            return _buildTickerItem(data);
          },
        ),
      ),
    );
  }

  Widget _buildTickerItem(MarketData data) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _buildIcon(data.type),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.symbol,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatPrice(data.price, data.symbol),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              _buildChangeIndicator(data),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price, String symbol) {
    if (symbol.contains('/')) {
      return price.toStringAsFixed(4);
    } else if (symbol == 'USD/JPY') {
      return price.toStringAsFixed(2);
    } else if (['GDP', 'UNEMP', 'CPI', 'FED'].contains(symbol)) {
      return '${price.toStringAsFixed(2)}%';
    } else if (['GOLD', 'SILVER', 'OIL', 'COPPER'].contains(symbol)) {
      return '\$${price.toStringAsFixed(2)}';
    }

    if (price >= 1000) {
      return '\$${price.toStringAsFixed(0)}';
    } else if (price >= 10) {
      return '\$${price.toStringAsFixed(2)}';
    } else if (price >= 1) {
      return '\$${price.toStringAsFixed(3)}';
    } else {
      return '\$${price.toStringAsFixed(4)}';
    }
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'crypto':
        iconData = FontAwesomeIcons.bitcoin;
        color = AppTheme.primaryTeal;
        break;
      case 'stock':
        iconData = FontAwesomeIcons.chartLine;
        color = AppTheme.primaryPurple;
        break;
      case 'forex':
        iconData = FontAwesomeIcons.exchangeAlt;
        color = AppTheme.secondaryTeal;
        break;
      case 'commodity':
        iconData = FontAwesomeIcons.coins;
        color = AppTheme.warningOrange;
        break;
      case 'indicator':
        iconData = FontAwesomeIcons.chartBar;
        color = AppTheme.secondaryPurple;
        break;
      default:
        iconData = FontAwesomeIcons.dollarSign;
        color = AppTheme.warningOrange;
    }

    return Icon(iconData, color: color, size: 16);
  }

  Widget _buildChangeIndicator(MarketData data) {
    final isPositive = data.isPositive;
    final color = isPositive ? AppTheme.successGreen : AppTheme.errorRed;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 2),
          Text(
            '${data.changePercent.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MarketSummaryCard extends StatelessWidget {
  final List<MarketData> stockData;
  final List<MarketData> cryptoData;

  const MarketSummaryCard({
    super.key,
    required this.stockData,
    required this.cryptoData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardDark, AppTheme.cardDark.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.glowShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Overview',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMarketSection(
                  'Stocks',
                  stockData,
                  AppTheme.primaryPurple,
                  FontAwesomeIcons.chartLine,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMarketSection(
                  'Crypto',
                  cryptoData,
                  AppTheme.primaryTeal,
                  FontAwesomeIcons.bitcoin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSection(
    String title,
    List<MarketData> data,
    Color color,
    IconData icon,
  ) {
    final positiveCount = data.where((d) => d.isPositive).length;
    final totalCount = data.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$positiveCount/$totalCount',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Positive',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
