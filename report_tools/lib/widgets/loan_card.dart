import 'package:flutter/material.dart';

class LoanCard extends StatelessWidget {
  final String itemName;
  final String schoolName;
  final String date;
  final String status;
  final bool isOverdue;

  const LoanCard({
    super.key,
    required this.itemName,
    required this.schoolName,
    required this.date,
    required this.status,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schoolName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Pinjam: $date",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      "Ketuk untuk kembali",
                      style: TextStyle(
                        fontSize: 11, 
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: Colors.deepPurple),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}