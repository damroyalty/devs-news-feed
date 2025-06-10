import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/news_article.dart';
import '../theme/app_theme.dart';

class NewsCard extends StatefulWidget {
  final NewsArticle article;
  final bool isCompact;

  const NewsCard({super.key, required this.article, this.isCompact = false});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildCard(context),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardDark, AppTheme.cardDark.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(widget.article.url),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: widget.isCompact
                ? _buildCompactContent()
                : _buildFullContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        if (widget.article.imageUrl != null) ...[
          _buildImage(),
          const SizedBox(height: 12),
        ],
        _buildTitle(),
        const SizedBox(height: 8),
        _buildDescription(),
        const SizedBox(height: 12),
        _buildFooter(),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.article.imageUrl != null) ...[
          _buildCompactImage(),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildTitle(),
              const SizedBox(height: 4),
              _buildCompactDescription(),
              const SizedBox(height: 8),
              _buildCompactFooter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(),
                _getCategoryColor().withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.article.category.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.article.source,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient.scale(0.3),
        ),
        child: CachedNetworkImage(
          imageUrl: widget.article.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
            ),
            child: const Icon(
              Icons.image_not_supported,
              color: AppTheme.textSecondary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient.scale(0.3),
        ),
        child: CachedNetworkImage(
          imageUrl: widget.article.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryTeal,
                  ),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
            ),
            child: const Icon(
              Icons.image_not_supported,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.article.title,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: widget.isCompact ? 14 : 18,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      maxLines: widget.isCompact ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.article.description,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompactDescription() {
    return Text(
      widget.article.description,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (widget.article.author != null) ...[
          Icon(Icons.person_outline, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 4),
          Text(
            widget.article.author!,
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          ),
          const SizedBox(width: 12),
        ],
        Icon(Icons.access_time, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 4),
        Text(
          _formatTime(widget.article.publishedAt),
          style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
        ),
        const Spacer(),
        if (widget.article.sentimentScore != null) _buildSentimentIndicator(),
      ],
    );
  }

  Widget _buildCompactFooter() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 12, color: AppTheme.textTertiary),
        const SizedBox(width: 4),
        Text(
          _formatTime(widget.article.publishedAt),
          style: const TextStyle(color: AppTheme.textTertiary, fontSize: 10),
        ),
        const Spacer(),
        if (widget.article.sentimentScore != null) _buildSentimentIndicator(),
      ],
    );
  }

  Widget _buildSentimentIndicator() {
    final score = widget.article.sentimentScore!;
    final color = score > 0.3
        ? AppTheme.successGreen
        : score < -0.3
        ? AppTheme.errorRed
        : AppTheme.warningOrange;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.article.category) {
      case 'crypto':
        return AppTheme.primaryTeal;
      case 'stocks':
        return AppTheme.primaryPurple;
      case 'economic':
        return AppTheme.warningOrange;
      default:
        return AppTheme.secondaryTeal;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
