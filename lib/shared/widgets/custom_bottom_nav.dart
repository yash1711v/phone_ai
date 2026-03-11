import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom Bottom Navigation Bar with SVG icons
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final BottomNavStyle style;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final int? badgeCount;
  final int? badgeIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.style = BottomNavStyle.classic,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.badgeCount,
    this.badgeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;
    final selectedCol = selectedColor ?? theme.primaryColor;
    final unselectedCol = unselectedColor ?? Colors.grey;

    final items = [
      _NavItem(iconPath: 'assets/icons/inbox.svg', label: 'Inbox'),
      _NavItem(iconPath: 'assets/icons/phone.svg', label: 'Calls'),
      _NavItem(iconPath: 'assets/icons/dial.svg', label: 'Dial'),
      _NavItem(iconPath: 'assets/icons/contact.svg', label: 'Contacts'),
      _NavItem(iconPath: 'assets/icons/settings.svg', label: 'Settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildNavBar(items, selectedCol, unselectedCol),
      ),
    );
  }

  Widget _buildNavBar(List<_NavItem> items, Color selectedCol, Color unselectedCol) {
    switch (style) {
      case BottomNavStyle.classic:
        return _ClassicNavBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedColor: selectedCol,
          unselectedColor: unselectedCol,
          badgeCount: badgeCount,
          badgeIndex: badgeIndex,
        );
      case BottomNavStyle.withIndicator:
        return _IndicatorNavBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedColor: selectedCol,
          unselectedColor: unselectedCol,
          badgeCount: badgeCount,
          badgeIndex: badgeIndex,
        );
      case BottomNavStyle.rounded:
        return _RoundedNavBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedColor: selectedCol,
          unselectedColor: unselectedCol,
          badgeCount: badgeCount,
          badgeIndex: badgeIndex,
        );
      case BottomNavStyle.minimal:
        return _MinimalNavBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedColor: selectedCol,
          unselectedColor: unselectedCol,
          badgeCount: badgeCount,
          badgeIndex: badgeIndex,
        );
    }
  }
}

enum BottomNavStyle {
  classic,
  withIndicator,
  rounded,
  minimal,
}

class _NavItem {
  final String iconPath;
  final String label;

  _NavItem({required this.iconPath, required this.label});
}

// SVG Icon Widget with color filter
class _SvgIcon extends StatelessWidget {
  final String assetPath;
  final Color color;
  final double size;

  const _SvgIcon({
    required this.assetPath,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

// Classic Style - Simple with labels
class _ClassicNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final int? badgeCount;
  final int? badgeIndex;

  const _ClassicNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    this.badgeCount,
    this.badgeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;
          final hasBadge = badgeIndex == index && badgeCount != null;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _SvgIcon(
                        assetPath: item.iconPath,
                        color: isSelected ? selectedColor : unselectedColor,
                        size: 26,
                      ),
                      if (hasBadge)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: _Badge(count: badgeCount!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// With Indicator Style - Highlighted selection box
class _IndicatorNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final int? badgeCount;
  final int? badgeIndex;

  const _IndicatorNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    this.badgeCount,
    this.badgeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: selectedColor.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;
            final hasBadge = badgeIndex == index && badgeCount != null;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                      color: selectedColor.withOpacity(0.3),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _SvgIcon(
                            assetPath: item.iconPath,
                            color: isSelected ? selectedColor : unselectedColor,
                            size: 26,
                          ),
                          if (hasBadge)
                            Positioned(
                              right: -8,
                              top: -4,
                              child: _Badge(count: badgeCount!),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Rounded Style - Circular background for selected item
class _RoundedNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final int? badgeCount;
  final int? badgeIndex;

  const _RoundedNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    this.badgeCount,
    this.badgeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;
          final hasBadge = badgeIndex == index && badgeCount != null;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedColor.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _SvgIcon(
                          assetPath: item.iconPath,
                          color: isSelected ? selectedColor : unselectedColor,
                          size: 26,
                        ),
                        if (hasBadge)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: _Badge(count: badgeCount!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? selectedColor : unselectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Minimal Style - Only icons, labels on selected
class _MinimalNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final int? badgeCount;
  final int? badgeIndex;

  const _MinimalNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    this.badgeCount,
    this.badgeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;
          final hasBadge = badgeIndex == index && badgeCount != null;

          return InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _SvgIcon(
                        assetPath: item.iconPath,
                        color: isSelected ? selectedColor : unselectedColor,
                        size: 26,
                      ),
                      if (hasBadge)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: _Badge(count: badgeCount!),
                        ),
                    ],
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selectedColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Badge Widget
class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}