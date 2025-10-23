// 📁 lib/screens/create_employee.dart

import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../db/database_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';


class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

final _formatter = NumberFormat('#,###', 'id_ID');

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  // 🔹 Semua controller untuk field karyawan
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressKTPController = TextEditingController();
  final _addressNowController = TextEditingController();
  final _ktaNumberController = TextEditingController();
  final _ktaExpiredController = TextEditingController();
  final _joinDateController = TextEditingController();
  final _placementController = TextEditingController();
  final _statusController = TextEditingController();
  final _bpjsHealthController = TextEditingController();
  final _bpjsTKController = TextEditingController();
  final _salaryBasicController = TextEditingController();
  final _allowanceHouseController = TextEditingController();
  final _allowanceMealController = TextEditingController();
  final _allowanceTransportController = TextEditingController();
  final _allowancePositionController = TextEditingController();
  final _deductionBPJSHealthController = TextEditingController();
  final _deductionBPJSTKController = TextEditingController();
  final _takeHomePayController = TextEditingController();

  String? _photoPath;

  // 🔹 Fungsi untuk pilih foto dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
      });
    }
  }

  // 🔹 Fungsi untuk simpan data karyawan ke database
  Future<void> _saveEmployee() async {
    
    // Validasi input
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID, Nama dan No HP wajib diisi!')),
      );
      return;
    }

    String finalPhotoPath = ''; // Local variable to hold the final saved photo path

    // 🔹 Jika ada foto yang dipilih, simpan ke folder `employee_photos`
    if (_photoPath != null && _idController.text.isNotEmpty) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final photosDir = Directory('${directory.path}_Photo');

        // Buat folder jika belum ada
        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }

        // Buat nama file berdasarkan ID Karyawan (clean special characters)
        final safeId = _idController.text.replaceAll(RegExp(r'[^\w\s]'), ''); // Removed \s to allow spaces, but typically IDs are without spaces. If your IDs can have spaces, consider how you want to handle them in filenames.
        final fileName = '$safeId.jpg';
        final newPath = path.join(photosDir.path, fileName);

        // Salin file ke folder tujuan
        await File(_photoPath!).copy(newPath);

        finalPhotoPath = newPath; // Store the actual saved path
        debugPrint('✅ Foto berhasil disimpan di: $finalPhotoPath');
        
      } catch (e) {
        debugPrint('❌ Gagal menyimpan foto: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan foto: $e')),
        );
      }
    }

    final employee = EmployeeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      idCard: _idController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      birthPlace: _birthPlaceController.text,
      birthDate: _birthDateController.text,
      addressKTP: _addressKTPController.text,
      addressNow: _addressNowController.text,
      ktaNumber: _ktaNumberController.text,
      ktaExpired: _ktaExpiredController.text,
      joinDate: _joinDateController.text,
      placement: _placementController.text,
      status: _statusController.text,
      bpjsHealth: _bpjsHealthController.text,
      bpjsTK: _bpjsTKController.text,
      salaryBasic: parseCurrency(_salaryBasicController),
      allowanceHouse: parseCurrency(_allowanceHouseController),
      allowanceMeal: parseCurrency(_allowanceMealController),
      allowanceTransport: parseCurrency(_allowanceTransportController),
      allowancePosition: parseCurrency(_allowancePositionController),
      deductionBPJSHealth: parseCurrency(_deductionBPJSHealthController),
      deductionBPJSTK: parseCurrency(_deductionBPJSTKController),
      takeHomePay: parseCurrency(_takeHomePayController),
      photoPath: finalPhotoPath, // <<< Use the local variable here
    );

    try {
      await DatabaseHelper.instance.insertEmployee(employee);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data karyawan berhasil disimpan!')),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error saat simpan: $e')),
      );
    }
  }

  void attachCurrencyFormatter(TextEditingController controller) {
    bool isFormatting = false; // 🔒 mencegah format berulang

    controller.addListener(() {
      if (isFormatting) return;

      final rawText = controller.text.replaceAll('.', '').replaceAll('Rp', '').replaceAll(' ', '');
      if (rawText.isEmpty) return;

      final value = double.tryParse(rawText);
      if (value == null) return;

      final formatted = _formatter.format(value).replaceAll(',', '.');

      if (formatted != controller.text) {
        isFormatting = true;
        controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
        isFormatting = false;
      }
    });
  }

double parseCurrency(TextEditingController controller) {
  return double.tryParse(
    controller.text.replaceAll('.', '').replaceAll('Rp', '').trim(),
  ) ?? 0.0;
}

  // 🔹 Fungsi hitung otomatis TakeHomePay
void _calculateTakeHome() {
  double salary = parseCurrency(_salaryBasicController);
  double house = parseCurrency(_allowanceHouseController);
  double meal = parseCurrency(_allowanceMealController);
  double transport = parseCurrency(_allowanceTransportController);
  double position = parseCurrency(_allowancePositionController);
  double bpjsHealth = parseCurrency(_deductionBPJSHealthController);
  double bpjsTK = parseCurrency(_deductionBPJSTKController);

  // Hitung potongan BPJS (misal 5% dan 3% dari gaji)
  // double bpjsHealth = salary * 0.05;
  // double bpjsTK = salary * 0.03;

  // _deductionBPJSHealthController.text = bpjsHealth.toStringAsFixed(0);
  // _deductionBPJSTKController.text = bpjsTK.toStringAsFixed(0);

  double takeHome = salary + house + meal + transport + position + bpjsHealth + bpjsTK;

  _takeHomePayController.text = NumberFormat('#,###', 'id_ID')
      .format(takeHome)
      .replaceAll(',', '.');
}

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _addressKTPController.dispose();
    _addressNowController.dispose();
    _ktaNumberController.dispose();
    _ktaExpiredController.dispose();
    _joinDateController.dispose();
    _placementController.dispose();
    _statusController.dispose();
    _bpjsHealthController.dispose();
    _bpjsTKController.dispose();
    _salaryBasicController.dispose();
    _allowanceHouseController.dispose();
    _allowanceMealController.dispose();
    _allowanceTransportController.dispose();
    _allowancePositionController.dispose();
    _deductionBPJSHealthController.dispose();
    _deductionBPJSTKController.dispose();
    _takeHomePayController.dispose();
    super.dispose();
  }

@override
void initState() {
  super.initState();

  // Tambahkan formatter ke semua field nominal
  attachCurrencyFormatter(_bpjsHealthController);
  attachCurrencyFormatter(_bpjsTKController);
  attachCurrencyFormatter(_salaryBasicController);
  attachCurrencyFormatter(_allowanceHouseController);
  attachCurrencyFormatter(_allowanceMealController);
  attachCurrencyFormatter(_allowanceTransportController);
  attachCurrencyFormatter(_allowancePositionController);
  attachCurrencyFormatter(_deductionBPJSHealthController);
  attachCurrencyFormatter(_deductionBPJSTKController);
  attachCurrencyFormatter(_takeHomePayController);
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Create Data Karyawan'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Karyawan
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _photoPath != null ? FileImage(File(_photoPath!)) : null,
                  child: _photoPath == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 16),

            // ID
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Nama
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // No HP
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No HP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Tempat Lahir
            TextField(
              controller: _birthPlaceController,
              decoration: const InputDecoration(
                labelText: 'Tempat Lahir',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Tanggal Lahir
            TextField(
              controller: _birthDateController,
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _birthDateController.text =
                        "${picked.day}-${picked.month}-${picked.year}";
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 12),

            // Alamat KTP
            TextField(
              controller: _addressKTPController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat KTP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Alamat Sekarang
            TextField(
              controller: _addressNowController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat Sekarang',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // No KTA
            TextField(
              controller: _ktaNumberController,
              decoration: const InputDecoration(
                labelText: 'No KTA',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Tanggal KTA Expired
            TextField(
              controller: _ktaExpiredController,
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _ktaExpiredController.text =
                        "${picked.day}-${picked.month}-${picked.year}";
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Tanggal KTA Expired',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 12),

            // Tanggal Join
            TextField(
              controller: _joinDateController,
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _joinDateController.text =
                        "${picked.day}-${picked.month}-${picked.year}";
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Tanggal Join',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 12),

            // Penempatan
            TextField(
              controller: _placementController,
              decoration: const InputDecoration(
                labelText: 'Penempatan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Status
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Status Karyawan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Gaji Basic
            TextField(
              controller: _salaryBasicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gaji Basic',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              onChanged: (_) => _calculateTakeHome(),
            ),
            SizedBox(height: 12),

            // Tunjangan Perumahan
            TextField(
              controller: _allowanceHouseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tunjangan Perumahan',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              onChanged: (_) => _calculateTakeHome(),
            ),
            SizedBox(height: 12),

            // Tunjangan Makan
            TextField(
              controller: _allowanceMealController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tunjangan Makan',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              onChanged: (_) => _calculateTakeHome(),
            ),
            SizedBox(height: 12),

            // Tunjangan Transport
            TextField(
              controller: _allowanceTransportController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tunjangan Transportasi',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              onChanged: (_) => _calculateTakeHome(),
            ),
            SizedBox(height: 12),

            // Tunjangan Jabatan
            TextField(
              controller: _allowancePositionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tunjangan Jabatan',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              onChanged: (_) => _calculateTakeHome(),
            ),
            SizedBox(height: 12),

            // Potongan BPJS Kesehatan
            TextField(
              controller: _deductionBPJSHealthController,
              enabled: true,
              decoration: const InputDecoration(
                labelText: 'Potongan BPJS Kesehatan',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            SizedBox(height: 12),

            // Potongan BPJS TK
            TextField(
              controller: _deductionBPJSTKController,
              enabled: true,
              decoration: const InputDecoration(
                labelText: 'Potongan BPJS TK',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            SizedBox(height: 12),

            // TakeHomePay
            TextField(
              controller: _takeHomePayController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Take Home Pay',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            SizedBox(height: 20),

            // Tombol Simpan
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveEmployee,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}