import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/news_provider.dart';
import '../widgets/animated_header.dart';
import '../widgets/category_filter.dart';
import '../widgets/market_ticker.dart';
import '../widgets/news_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showFab) {
      setState(() => _showFab = true);
      _fabController.forward();
    } else if (_scrollController.offset <= 200 && _showFab) {
      setState(() => _showFab = false);
      _fabController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            header: WaterDropHeader(
              complete: Icon(Icons.check, color: AppTheme.primaryTeal),
              waterDropColor: AppTheme.primaryTeal,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const SliverToBoxAdapter(
                  child: AnimatedHeader(),
                ),
                if (newsProvider.marketData.isNotEmpty)
                  SliverToBoxAdapter(
                    child: MarketTicker(marketData: newsProvider.marketData),
                  ),

                SliverToBoxAdapter(
                  child: CategoryFilter(
                    categories: newsProvider.categories,
                    selectedCategory: newsProvider.selectedCategory,
                    onCategorySelected: newsProvider.setCategory,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    'Latest News',
                    newsProvider.filteredNews.length,
                  ),
                ),

                if (newsProvider.error.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildErrorWidget(newsProvider.error),
                  ),

                if (newsProvider.isLoading)
                  const SliverToBoxAdapter(child: _LoadingWidget()),

                if (!newsProvider.isLoading &&
                    newsProvider.filteredNews.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final article = newsProvider.filteredNews[index];
                      return NewsCard(
                        article: article,
                        isCompact:
                            true,
                      );
                    }, childCount: newsProvider.filteredNews.length),
                  ),

                if (!newsProvider.isLoading &&
                    newsProvider.filteredNews.isEmpty &&
                    newsProvider.error.isEmpty)
                  const SliverToBoxAdapter(child: _EmptyStateWidget()),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _scrollToTop,
          backgroundColor: AppTheme.primaryTeal,
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppTheme.primaryTeal,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
          const SizedBox(height: 12),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: AppTheme.errorRed,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<NewsProvider>().refreshNews();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _onRefresh() async {
    try {
      await context.read<NewsProvider>().refreshNews();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading latest news...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.newspaper, color: AppTheme.primaryTeal, size: 60),
          ),
          const SizedBox(height: 24),
          const Text(
            'No news available',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try selecting a different category or check your connection',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<NewsProvider>().refreshNews();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

extension GradientScale on LinearGradient {
  LinearGradient scale(double factor) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors.map((color) => color.withOpacity(factor)).toList(),
    );
  }
}
