import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class CategoryFilter extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _buttonControllers;
  late List<Animation<double>> _buttonAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonControllers = List.generate(
      widget.categories.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _buttonAnimations = _buttonControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _buttonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 200 + (index * 100)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildCategoryButton(widget.categories[index], index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryButton(String category, int index) {
    final isSelected = category == widget.selectedCategory;

    return AnimatedBuilder(
      animation: _buttonAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonAnimations[index].value,
          child: Container(
            margin: const EdgeInsets.only(
              right: 6,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                onTap: () => _onCategoryTap(category, index),
                onTapDown: (_) => _buttonControllers[index].forward(),
                onTapUp: (_) => _buttonControllers[index].reverse(),
                onTapCancel: () => _buttonControllers[index].reverse(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? _getCategoryGradient(category)
                        : LinearGradient(
                            colors: [AppTheme.surfaceDark, AppTheme.cardDark],
                          ),
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? _getCategoryColor(category)
                          : AppTheme.textTertiary.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _getCategoryColor(
                                category,
                              ).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getCategoryDisplayName(category),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onCategoryTap(String category, int index) {
    if (category != widget.selectedCategory) {
      widget.onCategorySelected(category);
    }
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category) {
      case 'crypto':
        return LinearGradient(
          colors: [AppTheme.primaryTeal, AppTheme.secondaryTeal],
        );
      case 'stocks':
        return LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
        );
      case 'economic':
        return LinearGradient(
          colors: [
            AppTheme.warningOrange,
            AppTheme.warningOrange.withOpacity(0.8),
          ],
        );
      default:
        return AppTheme.accentGradient;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'crypto':
        return AppTheme.primaryTeal;
      case 'stocks':
        return AppTheme.primaryPurple;
      case 'economic':
        return AppTheme.warningOrange;
      default:
        return AppTheme.primaryTeal;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'all':
        return FontAwesomeIcons.globe;
      case 'crypto':
        return FontAwesomeIcons.bitcoin;
      case 'stocks':
        return FontAwesomeIcons.chartLine;
      case 'economic':
        return FontAwesomeIcons.university;
      default:
        return FontAwesomeIcons.newspaper;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All News';
      case 'crypto':
        return 'Crypto';
      case 'stocks':
        return 'Stocks';
      case 'economic':
        return 'Economic';
      default:
        return category.toUpperCase();
    }
  }
}
