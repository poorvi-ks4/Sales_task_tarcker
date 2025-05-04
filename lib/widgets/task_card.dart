import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.shopName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.synced ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.synced ? 'Synced' : 'Not Synced',
                    style: TextStyle(
                      color: task.synced ? Colors.green[700] : Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Product: ${task.productSold}'),
            const SizedBox(height: 4),
            Text('Quantity: ${task.quantity}'),
            const SizedBox(height: 4),
            Text('Amount: \$${task.amount.toStringAsFixed(2)}'),
            if (task.notes != null && task.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notes: ${task.notes}'),
            ],
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('MMM d, yyyy h:mm a').format(task.timestamp)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}