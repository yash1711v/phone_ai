import 'package:flutter/material.dart';

/// Custom chip selection widget
/// Displays a horizontal row of selectable chips
/// Returns only the selected item
class CustomChipSelection extends StatefulWidget {
  final List<String> items;
  final int initialIndex;
  final ValueChanged<String>? onSelectionChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const CustomChipSelection({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onSelectionChanged,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  State<CustomChipSelection> createState() => _CustomChipSelectionState();
}

class _CustomChipSelectionState extends State<CustomChipSelection> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? Colors.black;
    final unselectedColor = widget.unselectedColor ?? Colors.white;
    final selectedTextColor = widget.selectedTextColor ?? Colors.white;
    final unselectedTextColor = widget.unselectedTextColor ?? Colors.grey.shade700;

    return Row(
      children: List.generate(
        widget.items.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < widget.items.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onSelectionChanged?.call(widget.items[index]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: _selectedIndex == index ? selectedColor : unselectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedIndex == index
                      ? null
                      : Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                ),
                child: Center(
                  child: Text(
                    widget.items[index],
                    style: TextStyle(
                      color: _selectedIndex == index
                          ? selectedTextColor
                          : unselectedTextColor,
                      fontWeight: _selectedIndex == index
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
