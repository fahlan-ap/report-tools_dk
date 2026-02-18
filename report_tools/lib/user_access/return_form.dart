import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../widgets/photo_upload_area.dart';

class ReturnForm extends StatefulWidget {
  final Map<String, dynamic> loanData;

  const ReturnForm({super.key, required this.loanData});

  @override
  State<ReturnForm> createState() => _ReturnFormState();
}

class _ReturnFormState extends State<ReturnForm> {
  final UserController _controller = Get.find<UserController>();
  
  XFile? _pickedImage;
  bool _isSubmitting = false;

  // Ambil Foto
  Future<void> _handlePickImage() async {
    final XFile? image = await _controller.pickImage(context);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  // Konfirmasi Pengembalian
  Future<void> _submitReturn() async {
    if (_pickedImage == null) {
      Get.snackbar(
        "Peringatan", 
        "Foto bukti kondisi barang saat kembali wajib diunggah!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _controller.submitPengembalian(
        loanData: widget.loanData,
        fotoBuktiKembali: _pickedImage!,
      );

      Get.back();
      
      Get.snackbar(
        "Berhasil", 
        "Barang berhasil dikembalikan.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error submit pengembalian: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parsing data UI
    final List details = widget.loanData['detail_peminjaman'] ?? [];
    final String daftarBarang = details.map((d) => d['barang']?['nama_barang'] ?? 'Item').join(", ");
    final String namaSekolah = widget.loanData['sekolah']?['nama_sekolah'] ?? 'Sekolah';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text("Konfirmasi Pengembalian"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isSubmitting || _controller.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ringkasan Peminjaman",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.school, "Sekolah", namaSekolah),
                        const Divider(height: 20),
                        _buildInfoRow(Icons.inventory_2, "Daftar Barang", daftarBarang),
                        const Divider(height: 20),
                        _buildInfoRow(Icons.calendar_today, "Tanggal Pinjam", 
                          widget.loanData['waktu_pinjam'].toString().substring(0, 10)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  const Text(
                    "Foto Kondisi Barang (Saat Kembali)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _pickedImage != null
                      ? Stack(
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200, width: 2),
                                image: DecorationImage(
                                  image: kIsWeb 
                                      ? NetworkImage(_pickedImage!.path) 
                                      : FileImage(File(_pickedImage!.path)) as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8, top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => setState(() => _pickedImage = null),
                                ),
                              ),
                            ),
                          ],
                        )
                      : PhotoUploadArea(
                          label: "Ambil Foto Bukti Pengembalian", 
                          onTap: _handlePickImage,
                        ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _submitReturn,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        "Selesaikan & Simpan ke Riwayat",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}