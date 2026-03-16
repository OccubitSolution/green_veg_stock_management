/// Premium Widgets - Modern UI Components
///
/// Glassmorphism effects, animated counters, premium cards,
/// and other modern UI elements for a stunning user experience.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ============================================================================
// GLASS CARD - Frosted Glass Effect
// ============================================================================

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.blur = 20,
    this.backgroundColor,
    this.backgroundOpacity = 0.7,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ?? const EdgeInsets.all(AppTheme.spacingLG),
              decoration: BoxDecoration(
                gradient: gradientColors != null
                    ? LinearGradient(
                        colors: gradientColors!,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: gradientColors == null
                    ? (backgroundColor ?? Colors.white).withValues(
                        alpha: backgroundOpacity,
                      )
                    : null,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PREMIUM CARD - Elevated Card with Subtle Shadows
// ============================================================================

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool elevated;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevated ? AppTheme.elevatedShadow : AppTheme.cardShadow,
        border: Border.all(
          color: borderColor ?? AppTheme.borderLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMD),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GRADIENT HERO CARD - For Top Banner/Stats Cards
// ============================================================================

class GradientHeroCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GradientHeroCard({
    super.key,
    required this.child,
    this.gradientColors = const [Color(0xFF10B981), Color(0xFF059669)],
    this.padding,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.coloredShadow(gradientColors.first),
      ),
      child: child,
    );
  }
}

// ============================================================================
// PREMIUM STAT CARD - Animated Statistics Display
// ============================================================================

class PremiumStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final IconData? trendIcon;
  final Color? trendColor;

  const PremiumStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.subtitle,
    this.trendIcon,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              if (trendIcon != null)
                Icon(
                  trendIcon,
                  color: trendColor ?? AppTheme.success,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondaryLight),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: trendColor ?? AppTheme.textTertiaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// FLOATING ACTION TILE - Quick Action Button with Float Effect
// ============================================================================

class FloatingActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const FloatingActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<FloatingActionTile> createState() => _FloatingActionTileState();
}

class _FloatingActionTileState extends State<FloatingActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.95 : 1.0,
          _isPressed ? 0.95 : 1.0,
          1.0,
        ),
        padding: const EdgeInsets.all(AppTheme.spacingSM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          boxShadow: _isPressed ? AppTheme.cardShadow : AppTheme.softShadow,
          border: Border.all(
            color: widget.color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.15),
                    widget.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(widget.icon, color: widget.color, size: 26),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODERN SEARCH BAR
// ============================================================================

class ModernSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;

  const ModernSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.borderLight.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText ?? 'search'.tr,
          hintStyle: TextStyle(color: AppTheme.textTertiaryLight),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondaryLight,
          ),
          suffixIcon: showClearButton && (controller?.text.isNotEmpty ?? false)
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.textSecondaryLight,
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingMD,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ENHANCED PRODUCT SEARCH SECTION - Better UX for Order Entry
// ============================================================================

class ProductSearchSection extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? title;
  final String? subtitle;

  const ProductSearchSection({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.surfaceLight.withValues(alpha: 0.5)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'search_and_add_products'.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryLight,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLG),
          // Large, prominent search bar
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG - 2),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText ?? 'search_products'.tr,
                  hintStyle: TextStyle(
                    color: AppTheme.textTertiaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller ?? TextEditingController(),
                    builder: (context, value, child) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.textTertiaryLight.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.textSecondaryLight,
                            size: 16,
                          ),
                        ),
                        onPressed: () {
                          controller?.clear();
                          onClear?.call();
                        },
                      );
                    },
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMD,
                    vertical: AppTheme.spacingMD,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER - Modern Section Title
// ============================================================================

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onViewAll;
  final String? viewAllText;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.onViewAll,
    this.viewAllText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(icon, size: 16, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: AppTheme.spacingSM),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewAllText ?? 'view_all'.tr,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODERN FILTER CHIP - Animated Category Filter
// ============================================================================

class ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final IconData? icon;
  final VoidCallback onSelected;

  const ModernFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.color,
    this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected();
      },
      child: AnimatedContainer(
        duration: AppTheme.animNormal,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [chipColor, chipColor.withValues(alpha: 0.85)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.borderLight,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected ? AppTheme.coloredShadow(chipColor) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT CARD - Modern Product List Item
// ============================================================================

class ModernProductCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? price;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModernProductCard({
    super.key,
    required this.name,
    this.subtitle,
    this.price,
    this.icon = Icons.eco,
    this.iconColor = AppTheme.primaryColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: 0.15),
                  iconColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing
          if (trailing != null)
            trailing!
          else if (price != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                price!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// PRICE INPUT CARD - For Daily Prices Entry
// ============================================================================

class PriceInputCard extends StatelessWidget {
  final String name;
  final String? unit;
  final TextEditingController? priceController;
  final ValueChanged<String>? onPriceChanged;
  final IconData icon;
  final Color iconColor;
  final double? previousPrice;
  final double? currentPrice;
  final double? yesterdayPrice;

  const PriceInputCard({
    super.key,
    required this.name,
    this.unit,
    this.priceController,
    this.onPriceChanged,
    this.icon = Icons.eco,
    this.iconColor = AppTheme.primaryColor,
    this.previousPrice,
    this.currentPrice,
    this.yesterdayPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Determine price trend
    IconData? trendIcon;
    Color? trendColor;
    if (previousPrice != null && currentPrice != null) {
      if (currentPrice! > previousPrice!) {
        trendIcon = Icons.trending_up_rounded;
        trendColor = AppTheme.error;
      } else if (currentPrice! < previousPrice!) {
        trendIcon = Icons.trending_down_rounded;
        trendColor = AppTheme.success;
      }
    }

    return PremiumCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: 0.15),
                  iconColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      unit ?? 'kg',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    if (trendIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trendIcon, size: 14, color: trendColor),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Price Input
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 100,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                  onChanged: onPriceChanged,
                ),
              ),
              if (yesterdayPrice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${'yesterday'.tr}: ₹${yesterdayPrice!.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiaryLight,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE WIDGET
// ============================================================================

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODERN DATE SELECTOR
// ============================================================================

class ModernDateSelector extends StatelessWidget {
  final String dateText;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onTap;

  const ModernDateSelector({
    super.key,
    required this.dateText,
    required this.onPrevious,
    required this.onNext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        boxShadow: AppTheme.coloredShadow(AppTheme.primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
            onPressed: onPrevious,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SKELETON LOADERS
// ============================================================================

class SkeletonItem extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonItem({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = AppTheme.radiusMD,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.borderLight,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(duration: 800.ms, begin: 0.4, end: 1.0);
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  const SkeletonList({
    super.key,
    this.count = 6,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(AppTheme.spacingMD),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              SkeletonItem(
                height: 48,
                width: 48,
                borderRadius: AppTheme.radiusMD,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonItem(height: 14, width: 120),
                    SizedBox(height: 8),
                    SkeletonItem(height: 10, width: 80),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const SkeletonItem(
                height: 28,
                width: 60,
                borderRadius: AppTheme.radiusSM,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// ANIMATED GRADIENT BUTTON
// ============================================================================

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final List<Color> gradientColors;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradientColors = const [Color(0xFF10B981), Color(0xFF059669)],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: AppTheme.coloredShadow(gradientColors.first),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: SizedBox(
              height: 20,
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
