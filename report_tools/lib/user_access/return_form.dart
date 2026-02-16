import 'package:flutter/material.dart';
import '../widgets/photo_upload_area.dart';

class ReturnForm extends StatefulWidget {
  const ReturnForm({super.key});

  @override
  State<ReturnForm> createState() => _ReturnFormState();
}

class _ReturnFormState extends State<ReturnForm> {
  String selectedCondition = 'Baik / Normal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Pengembalian")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.deepPurple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Pastikan barang sudah bersih sebelum dikembalikan ke gudang.",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Kondisi Barang",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCondition,
              items:
                  ['Baik / Normal', 'Rusak Ringan', 'Rusak Berat / Hilang']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (val) {
                setState(() {
                  selectedCondition = val!;
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.check_circle_outline,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Catatan Tambahan (Opsional)",
                alignLabelWithHint: true,
                hintText: "Contoh: Kabel agak kotor karena debu...",
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Bukti Foto Pengembalian",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Menggunakan Widget yang sudah dipisah
            PhotoUploadArea(label: "Upload Foto Bukti", onTap: () {}),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Navigator.pop(context),
                child: const Text("Konfirmasi Pengembalian"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
