import 'package:flutter/material.dart';

class TodoFilterBar extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const TodoFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton(
            context,
            '全部',
            'all',
            Icons.list,
          ),
          _buildFilterButton(
            context,
            '待完成',
            'active',
            Icons.radio_button_unchecked,
          ),
          _buildFilterButton(
            context,
            '已完成',
            'completed',
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    String filterValue,
    IconData icon,
  ) {
    final isSelected = currentFilter == filterValue;
    final theme = Theme.of(context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          icon: Icon(
            icon,
            size: 16,
          ),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
            foregroundColor: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: () => onFilterChanged(filterValue),
        ),
      ),
    );
  }
}
