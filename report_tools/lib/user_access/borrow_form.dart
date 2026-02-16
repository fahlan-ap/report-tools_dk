import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'user_service.dart';
import '../widgets/photo_upload_area.dart';

class BorrowForm extends StatefulWidget {
  const BorrowForm({super.key});

  @override
  State<BorrowForm> createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  final UserService _controller = UserService();

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

  // Memastikan data sekolah dan barang diambil sesuai tabel public.sekolah & public.barang
  Future<void> _loadInitialData() async {
    try {
      final schools = await _controller.getSekolahList();
      final items = await _controller.getBarangList();
      setState(() {
        _schoolList = schools;
        _barangListDB = items;
      });
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e", 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Menggunakan fungsi pickImage dari UserService (Modal BottomSheet ala DTomato)
  Future<void> _handlePickImage() async {
    final XFile? image = await _controller.pickImage(context);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submitForm() async {
    // Validasi input sesuai kolom NOT NULL di database
    if (_selectedSchoolId == null || _selectedBarangIds.isEmpty || _pickedImage == null) {
      Get.snackbar("Peringatan", "Sekolah, Barang, dan Foto Bukti wajib diisi!", 
      backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Mengirim data ke controller. 
      // id_user akan diambil otomatis dari auth.currentUser.id di dalam service
      await _controller.submitPeminjaman(
        sekolahId: _selectedSchoolId!,
        barangIds: _selectedBarangIds,
        fotoBukti: _pickedImage!,
      );

      Get.back();
      Get.snackbar("Berhasil", "Peminjaman berhasil diajukan!", 
      backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan database: $e", 
      backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showItemSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Pilih Barang"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _barangListDB.length,
                  itemBuilder: (context, index) {
                    final item = _barangListDB[index];
                    final id = item['id'] as String; // id berbentuk UUID String
                    final isSelected = _selectedBarangIds.contains(id);

                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(item['nama_barang']),
                      activeColor: Colors.deepPurple,
                      onChanged: (bool? checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            _selectedBarangIds.add(id);
                          } else {
                            _selectedBarangIds.remove(id);
                          }
                        });
                        setState(() {}); // Update Chip di halaman utama
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text("Selesai", style: TextStyle(color: Colors.deepPurple))
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Peminjaman"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detail Peminjaman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // 1. Dropdown Sekolah (Mapping id_sekolah)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Sekolah Tujuan", 
                      prefixIcon: Icon(Icons.school, color: Colors.deepPurple),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSchoolId,
                    items: _schoolList.map((item) => DropdownMenuItem(
                      value: item['id'] as String, 
                      child: Text(item['nama_sekolah'])
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedSchoolId = val),
                  ),
                  const SizedBox(height: 16),

                  // 2. Multi Select Barang (Mapping detail_peminjaman)
                  InkWell(
                    onTap: _showItemSelectionDialog,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Daftar Barang", 
                        prefixIcon: Icon(Icons.inventory, color: Colors.deepPurple),
                        border: OutlineInputBorder(),
                      ),
                      child: _selectedBarangIds.isEmpty
                          ? const Text("Pilih barang...", style: TextStyle(color: Colors.grey))
                          : Wrap(
                              spacing: 8,
                              children: _selectedBarangIds.map((id) {
                                final item = _barangListDB.firstWhere((e) => e['id'] == id, orElse: () => {'nama_barang': '...'});
                                return Chip(
                                  label: Text(item['nama_barang']), 
                                  onDeleted: () => setState(() => _selectedBarangIds.remove(id))
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Bukti Kondisi Awal (Ukuran Asli)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // 3. Area Foto (Support Web & Mobile)
                  _pickedImage != null
                      ? Stack(
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
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
                                  onPressed: () => setState(() => _pickedImage = null)
                                )
                              ),
                            ),
                          ],
                        )
                      : PhotoUploadArea(
                          label: "Ketuk untuk pilih Kamera/Galeri", 
                          onTap: _handlePickImage
                        ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: _submitForm, 
                      child: const Text("Ajukan Peminjaman", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}