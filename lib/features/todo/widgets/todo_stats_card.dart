import 'package:flutter/material.dart';

class TodoStatsCard extends StatelessWidget {
  final Map<String, int> stats;

  const TodoStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final completionRate = total > 0 ? (completed / total * 100).toInt() : 0;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '总计',
                  total.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  '待完成',
                  pending.toString(),
                  Icons.assignment_late,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  '已完成',
                  completed.toString(),
                  Icons.assignment_turned_in,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '完成进度: $completionRate%',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
