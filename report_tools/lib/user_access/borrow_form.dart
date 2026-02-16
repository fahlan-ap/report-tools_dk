import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'user_service.dart'; // Import Controller Baru
import '../widgets/photo_upload_area.dart';

// UBAH NAMA CLASS DI SINI
class BorrowForm extends StatefulWidget {
  const BorrowForm({super.key});

  @override
  State<BorrowForm> createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  final UserService _controller = UserService();
  final ImagePicker _picker = ImagePicker();

  // Data Pilihan
  List<Map<String, dynamic>> _schoolList = [];
  List<Map<String, dynamic>> _barangListDB = [];

  String? _selectedSchoolId;
  final List<String> _selectedBarangIds = [];
  XFile? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final schools = await _controller.getSekolahList();
      final items = await _controller.getBarangList();
      setState(() {
        _schoolList = schools;
        _barangListDB = items;
      });
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    }
  }

  Future<void> _submitForm() async {
    if (_selectedSchoolId == null ||
        _selectedBarangIds.isEmpty ||
        _pickedImage == null) {
      Get.snackbar(
        "Peringatan",
        "Sekolah, Barang, dan Foto Bukti wajib diisi!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Konversi XFile ke File (Logic Mobile) sudah ditangani di controller

      await _controller.submitPeminjaman(
        sekolahId: _selectedSchoolId!,
        barangIds: _selectedBarangIds,
        fotoBukti: _pickedImage!,
      );

      Get.back(); // Tutup halaman form
      Get.snackbar(
        "Berhasil",
        "Data peminjaman tersimpan!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  // --- LOGIKA MULTI-SELECT BARANG ---
  void _showItemSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Pilih Barang"),
              content: SingleChildScrollView(
                child: ListBody(
                  children:
                      _barangListDB.map((item) {
                        final id = item['id'] as String;
                        final nama = item['nama_barang'] as String;
                        final isSelected = _selectedBarangIds.contains(id);

                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(nama),
                          activeColor: Colors.deepPurple,
                          onChanged: (bool? checked) {
                            setStateDialog(() {
                              if (checked == true) {
                                _selectedBarangIds.add(id);
                              } else {
                                _selectedBarangIds.remove(id);
                              }
                            });
                            setState(
                              () {},
                            ); // Update tampilan Chip di halaman utama
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Selesai"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate Chips untuk barang yang dipilih
    List<Widget> selectedChips =
        _selectedBarangIds.map((id) {
          final barang = _barangListDB.firstWhere(
            (element) => element['id'] == id,
            orElse: () => {'nama_barang': 'Unknown'},
          );
          return Chip(
            label: Text(
              barang['nama_barang'],
              style: const TextStyle(fontSize: 12),
            ),
            onDeleted: () => setState(() => _selectedBarangIds.remove(id)),
          );
        }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Form Peminjaman")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Peminjaman",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Dropdown Sekolah
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Sekolah Tujuan",
                        prefixIcon: Icon(
                          Icons.school,
                          color: Colors.deepPurple,
                        ),
                      ),
                      value: _selectedSchoolId,
                      items:
                          _schoolList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['nama_sekolah']),
                            );
                          }).toList(),
                      onChanged:
                          (val) => setState(() => _selectedSchoolId = val),
                    ),
                    const SizedBox(height: 16),

                    // 2. Multi Select Barang
                    InkWell(
                      onTap: _showItemSelectionDialog,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Daftar Barang",
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.deepPurple,
                          ),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child:
                            _selectedBarangIds.isEmpty
                                ? const Text(
                                  "Pilih barang...",
                                  style: TextStyle(color: Colors.grey),
                                )
                                : Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: selectedChips,
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Bukti Kondisi Awal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Upload Foto
                    _pickedImage != null
                        ? Stack(
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image:
                                      kIsWeb
                                          ? NetworkImage(_pickedImage!.path)
                                          : FileImage(File(_pickedImage!.path))
                                              as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed:
                                      () => setState(() => _pickedImage = null),
                                ),
                              ),
                            ),
                          ],
                        )
                        : PhotoUploadArea(
                          label: "Ketuk untuk ambil foto",
                          onTap: _pickImage,
                        ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Ajukan Peminjaman"),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
