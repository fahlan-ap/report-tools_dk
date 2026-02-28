import 'package:flutter/material.dart';

class ModernCard extends StatelessWidget {
  final String user;
  final String barang;
  final String sekolah;
  final String waktu;

  const ModernCard({
    super.key,
    required this.user,
    required this.barang,
    required this.sekolah,
    required this.waktu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Jarak antar card lebih rapat
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Radius lebih kecil agar terlihat compact
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
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 4, color: Colors.deepPurpleAccent),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar lebih kecil
                      CircleAvatar(
                        radius: 18, 
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        child: Text(user[0].toUpperCase(), 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            const Text("Teacher", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const _StatusBadge(),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  // Data rows dengan spacing lebih rapat
                  _buildDataRow(Icons.inventory_2_rounded, "Barang", barang, Colors.blue),
                  const SizedBox(height: 8),
                  _buildDataRow(Icons.location_on_rounded, "Tujuan", sekolah, Colors.orange),
                  const SizedBox(height: 8),
                  _buildDataRow(Icons.calendar_today_rounded, "Waktu", waktu, Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: const Text(
        "Dipinjam", 
        style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }
}