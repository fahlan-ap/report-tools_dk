import 'package:flutter/material.dart';

class PhotoUploadArea extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PhotoUploadArea({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.02), // Background tipis
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            style: BorderStyle.solid, // Bisa diganti Dash dengan Package lain, tapi solid pun oke
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_outlined, // Icon lebih representatif
                size: 32,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Format: JPG, PNG (Maks. 5MB)",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}