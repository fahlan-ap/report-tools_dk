import 'package:flutter/material.dart';

class LoanCard extends StatelessWidget {
  final String itemName;
  final String schoolName;
  final String date;
  final String status;
  final bool isOverdue;
  final VoidCallback? onTap;

  const LoanCard({
    super.key,
    required this.itemName,
    required this.schoolName,
    required this.date,
    required this.status,
    this.isOverdue = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Gari Aksen di Samping (Merah jika telat, Ungu jika normal)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 4, 
                color: isOverdue ? Colors.redAccent : Colors.deepPurpleAccent
              ),
            ),
            
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Icon Container Compact
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isOverdue ? Colors.red : Colors.deepPurple).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.inventory_2_rounded,
                              size: 20,
                              color: isOverdue ? Colors.redAccent : Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
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
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                Text(
                                  schoolName,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          
                          // Status Badge Compact
                          _buildStatusBadge(),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, thickness: 0.5),
                      ),
                      
                      // Footer Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 6),
                              Text(
                                date,
                                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const Row(
                            children: [
                              Text(
                                "Kembalikan",
                                style: TextStyle(
                                  fontSize: 11, 
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w700
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 16, color: Colors.deepPurple),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOverdue ? Colors.red.shade100 : Colors.orange.shade100,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isOverdue ? Colors.redAccent : Colors.orange[800],
          fontWeight: FontWeight.w900,
          fontSize: 9,
        ),
      ),
    );
  }
}