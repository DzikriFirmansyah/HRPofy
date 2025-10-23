import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:file_picker/file_picker.dart';
import '../models/employee_model.dart';
import '../db/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';


class ManageEmployeeScreen extends StatefulWidget {
  const ManageEmployeeScreen({super.key});

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

final _formatter = NumberFormat('#,###', 'id_ID');

class _ManageEmployeeScreenState extends State<ManageEmployeeScreen> {
  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  bool _isEditing = false;

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
  File? _photoFile;
  

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    // Tambahkan formatter untuk semua field nominal
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

  Future<void> _fetchEmployees() async {
    final employees = await DatabaseHelper.instance.getAllEmployees();
    setState(() {
      _employees = employees;
    });
  }

  // Fungsi pilih foto
Future<void> _pickPhoto() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _photoFile = File(pickedFile.path);
      _photoPath = pickedFile.path; // simpan path untuk database
    });
  }
}

void attachCurrencyFormatter(TextEditingController controller) {
  bool isFormatting = false; // untuk cegah loop listener

  controller.addListener(() {
    if (isFormatting) return;

    final rawText = controller.text
        .replaceAll('.', '')
        .replaceAll('Rp', '')
        .replaceAll(' ', '');
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

  // 🔹 Fungsi untuk pilih karyawan dari dropdown
  void _onEmployeeSelected(EmployeeModel employee) {
    setState(() {
      _selectedEmployee = employee;
      _isEditing = false;

      // Set semua controller
      _idController.text = employee.idCard;
      _nameController.text = employee.name;
      _phoneController.text = employee.phone;
      _birthPlaceController.text = employee.birthPlace;
      _birthDateController.text = employee.birthDate;
      _addressKTPController.text = employee.addressKTP;
      _addressNowController.text = employee.addressNow;
      _ktaNumberController.text = employee.ktaNumber;
      _ktaExpiredController.text = employee.ktaExpired;
      _joinDateController.text = employee.joinDate;
      _placementController.text = employee.placement;
      _statusController.text = employee.status;
      _bpjsHealthController.text = employee.bpjsHealth;
      _bpjsTKController.text = employee.bpjsTK;
      _salaryBasicController.text = employee.salaryBasic.toStringAsFixed(0);
      _allowanceHouseController.text = employee.allowanceHouse.toStringAsFixed(0);
      _allowanceMealController.text = employee.allowanceMeal.toStringAsFixed(0);
      _allowanceTransportController.text = employee.allowanceTransport.toStringAsFixed(0);
      _allowancePositionController.text = employee.allowancePosition.toStringAsFixed(0);
      _deductionBPJSHealthController.text = employee.deductionBPJSHealth.toStringAsFixed(0);
      _deductionBPJSTKController.text = employee.deductionBPJSTK.toStringAsFixed(0);
      _takeHomePayController.text = employee.takeHomePay.toStringAsFixed(0);
      // ✅ Gunakan path dari database  
      _photoPath = employee.photoPath;

      // ✅ Reset foto sementara agar tidak menampilkan foto karyawan lain
      _photoFile = null;
    });
  }

  // 🔹 Fungsi untuk hitung otomatis TakeHomePay
  void _calculateTakeHome() {
    double salary = parseCurrency(_salaryBasicController);
    double house = parseCurrency(_allowanceHouseController);
    double meal = parseCurrency(_allowanceMealController);
    double transport = parseCurrency(_allowanceTransportController);
    double position = parseCurrency(_allowancePositionController);
    double bpjsHealth = parseCurrency(_allowanceTransportController);
    double bpjsTK = parseCurrency(_allowancePositionController);

    // double bpjsHealth = salary * 0.05;
    // double bpjsTK = salary * 0.03;

    // _deductionBPJSHealthController.text = bpjsHealth.toStringAsFixed(0);
    // _deductionBPJSTKController.text = bpjsTK.toStringAsFixed(0);

    double takeHome = salary + house + meal + transport + position + bpjsHealth + bpjsTK;

    _takeHomePayController.text =
        _formatter.format(takeHome).replaceAll(',', '.');
  }

  // 🔹 Fungsi simpan perubahan (update)
  Future<void> _updateEmployee() async {
    if (_selectedEmployee == null) return;

    String finalPhotoPath = ''; // Local variable to hold the final saved photo path

  //🔹 Jika ada foto yang dipilih, simpan ke folder `employee_photos`
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

        // 🔸 Jika ada foto lama dengan ID ini, hapus dulu (supaya tidak ada cache ganda)
        final oldFile = File(newPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }

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
    } else {
        // 🔹 Kalau tidak ada foto baru, tetap gunakan foto lama
        finalPhotoPath = _selectedEmployee!.photoPath;
      }
    
    final updatedEmployee = EmployeeModel(
      id: _selectedEmployee!.id,
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
      photoPath: finalPhotoPath.isNotEmpty
        ? finalPhotoPath
        : _selectedEmployee!.photoPath, // tetap pakai foto lama kalau tidak ganti
    );

    await DatabaseHelper.instance.updateEmployee(updatedEmployee);
    await _fetchEmployees();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data karyawan berhasil diperbarui!')),
    );

    setState(() {
      _selectedEmployee = updatedEmployee; // refresh data terpilih
      _photoFile = null; // hapus foto sementara
      _photoPath = updatedEmployee.photoPath; // gunakan foto yang tersimpan di DB
    });

    setState(() {
      _isEditing = false;
    });
  }


    // 🔹 Fungsi hapus karyawan
  Future<void> _deleteEmployee() async {
    if (_selectedEmployee == null) return;

    try {
      // 🔸 Hapus foto karyawan dari folder Document_Photo
      if (_selectedEmployee!.photoPath.isNotEmpty) {
        final file = File(_selectedEmployee!.photoPath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️ Foto dihapus: ${_selectedEmployee!.photoPath}');
        } else {
          debugPrint('⚠️ Foto tidak ditemukan di: ${_selectedEmployee!.photoPath}');
        }
      }

      // 🔸 Hapus data dari database
      await DatabaseHelper.instance.deleteEmployee(_selectedEmployee!.id);

      // 🔸 Refresh data karyawan
      await _fetchEmployees();

      // 🔸 Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data karyawan dan foto berhasil dihapus!')),
      );

      // 🔸 Reset state form
      setState(() {
        _selectedEmployee = null;
        _isEditing = false;
        _clearForm();
      });
    } catch (e) {
      debugPrint('❌ Gagal menghapus karyawan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus karyawan: $e')),
      );
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final employees = await DatabaseHelper.instance.getAllEmployees();

      // Buat workbook baru
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];
      sheet.name = 'Data Karyawan';

      // Header kolom
      final headers = [
        'ID',
        'Nama',
        'No HP',
        'Tempat Lahir',
        'Tanggal Lahir',
        'Alamat KTP',
        'Alamat Sekarang',
        'No KTA',
        'KTA Expired',
        'Tanggal Join',
        'Penempatan',
        'Status',
        'BPJS Kesehatan',
        'BPJS TK',
        'Gaji Pokok',
        'Tunj. Rumah',
        'Tunj. Makan',
        'Tunj. Transport',
        'Tunj. Jabatan',
        'Pot. BPJS Kes',
        'Pot. BPJS TK',
        'Take Home Pay'
      ];

      // Tulis header ke baris pertama
      for (var i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
        sheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
      }

      // Isi data karyawan
      for (var row = 0; row < employees.length; row++) {
        final e = employees[row];
        final data = [
          e.idCard,
          e.name,
          e.phone,
          e.birthPlace,
          e.birthDate,
          e.addressKTP,
          e.addressNow,
          e.ktaNumber,
          e.ktaExpired,
          e.joinDate,
          e.placement,
          e.status,
          e.bpjsHealth,
          e.bpjsTK,
          e.salaryBasic,
          e.allowanceHouse,
          e.allowanceMeal,
          e.allowanceTransport,
          e.allowancePosition,
          e.deductionBPJSHealth,
          e.deductionBPJSTK,
          e.takeHomePay,
        ];

        for (var col = 0; col < data.length; col++) {
          sheet.getRangeByIndex(row + 2, col + 1).setText(data[col]?.toString() ?? '');
        }
      }

      // Simpan file ke direktori dokumen
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}_Export.xlsx");
      await file.writeAsBytes(bytes, flush: true);

      // Notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Data berhasil diekspor ke: ${file.path}")),
      );

      debugPrint("📁 File disimpan di: ${file.path}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gagal ekspor data: $e")),
      );
    }
  }

  Future<void> _importEmployeesFromCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return; // batal pilih file

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final csvData = const CsvToListConverter().convert(csvString);

      // Asumsikan baris pertama adalah header
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];

        final employee = EmployeeModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          idCard: row[0].toString(),
          name: row[1].toString(),
          phone: row[2].toString(),
          birthPlace: row[3].toString(),
          birthDate: row[4].toString(),
          addressKTP: row[5].toString(),
          addressNow: row[6].toString(),
          ktaNumber: row[7].toString(),
          ktaExpired: row[8].toString(),
          joinDate: row[9].toString(),
          placement: row[10].toString(),
          status: row[11].toString(),
          bpjsHealth: row[12].toString(),
          bpjsTK: row[13].toString(),
          salaryBasic: double.tryParse(row[14].toString()) ?? 0.0,
          allowanceHouse: double.tryParse(row[15].toString()) ?? 0.0,
          allowanceMeal: double.tryParse(row[16].toString()) ?? 0.0,
          allowanceTransport: double.tryParse(row[17].toString()) ?? 0.0,
          allowancePosition: double.tryParse(row[18].toString()) ?? 0.0,
          deductionBPJSHealth: double.tryParse(row[19].toString()) ?? 0.0,
          deductionBPJSTK: double.tryParse(row[20].toString()) ?? 0.0,
          takeHomePay: double.tryParse(row[21].toString()) ?? 0.0,
          photoPath: '', // foto tidak diimpor
        );

        await DatabaseHelper.instance.insertEmployee(employee);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data karyawan berhasil diimport dari CSV!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengimpor data: $e')),
      );
    }
  }


  void _clearForm() {
    _idController.clear();
    _nameController.clear();
    _phoneController.clear();
    _birthPlaceController.clear();
    _birthDateController.clear();
    _addressKTPController.clear();
    _addressNowController.clear();
    _ktaNumberController.clear();
    _ktaExpiredController.clear();
    _joinDateController.clear();
    _placementController.clear();
    _statusController.clear();
    _bpjsHealthController.clear();
    _bpjsTKController.clear();
    _salaryBasicController.clear();
    _allowanceHouseController.clear();
    _allowanceMealController.clear();
    _allowanceTransportController.clear();
    _allowancePositionController.clear();
    _deductionBPJSHealthController.clear();
    _deductionBPJSTKController.clear();
    _takeHomePayController.clear();
    _photoPath = null;
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

  @override // <--- This is the crucial addition
  Widget build(BuildContext context) {
    // Pastikan selectedEmployee masih ada di list
    if (_selectedEmployee != null && !_employees.contains(_selectedEmployee)) {
      _selectedEmployee = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employee'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20,0,0,0),
            child:
            DropdownButton<EmployeeModel>(
            hint: const Text('Pilih Karyawan'),
            value: _selectedEmployee,
            items: _employees.map((e) {
              return DropdownMenuItem<EmployeeModel>(
                value: e,
                child: Text(e.idCard),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) _onEmployeeSelected(value);
            },
          ),
          ),

          // Tombol Edit / Hapus
            Row(
              children: [
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _exportToExcel,
                  child: const Text('Export'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _importEmployeesFromCSV,
                  child: const Text('Import'),
                ),
                const SizedBox(width: 8),
                if (_selectedEmployee != null)
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _deleteEmployee,
                        child: const Text('Hapus'),
                      ),
                    ],
                )
              ],
            ),

          // Form edit (hanya jika _isEditing true)
          if (_isEditing && _selectedEmployee != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto
                    (_photoFile != null)
                        ? Image.file(
                            _photoFile!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : (_photoPath != null &&
                                _photoPath!.isNotEmpty)
                            ? Image.file(
                                File(_photoPath!),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 150,
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 80),
                              ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo),
                      label: const Text('Pilih Foto'),
                    ),
                    const SizedBox(height: 12),

                    // ID Karyawan
                    TextField(
                      controller: _idController,
                      decoration: const InputDecoration(labelText: 'ID', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Nama
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // No HP
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'No HP', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Tempat Lahir
                    TextField(
                      controller: _birthPlaceController,
                      decoration: const InputDecoration(labelText: 'Tempat Lahir', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Tanggal Lahir
                    TextField(
                      controller: _birthDateController,
                      enabled: true,
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
                    const SizedBox(height: 12),

                    // Alamat KTP
                    TextField(
                      controller: _addressKTPController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Alamat KTP', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Alamat Sekarang
                    TextField(
                      controller: _addressNowController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Alamat Sekarang', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // No KTA
                    TextField(
                      controller: _ktaNumberController,
                      decoration: const InputDecoration(labelText: 'No KTA', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Tanggal KTA Expired
                    TextField(
                      controller: _ktaExpiredController,
                      enabled: true,
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
                    const SizedBox(height: 12),

                    // Tanggal Join
                    TextField(
                      controller: _joinDateController,
                      enabled: true,
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
                    const SizedBox(height: 12),

                    // Penempatan
                    TextField(
                      controller: _placementController,
                      decoration: const InputDecoration(labelText: 'Penempatan', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Status
                    TextField(
                      controller: _statusController,
                      decoration: const InputDecoration(labelText: 'Status Karyawan', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Gaji Basic
                    TextField(
                      controller: _salaryBasicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Gaji Basic', prefixText: 'Rp ', border: OutlineInputBorder()),
                      onChanged: (_) => _calculateTakeHome(),
                    ),
                    const SizedBox(height: 12),

                    // Tunjangan
                    TextField(
                      controller: _allowanceHouseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tunjangan Perumahan', prefixText: 'Rp ', border: OutlineInputBorder()),
                      onChanged: (_) => _calculateTakeHome(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _allowanceMealController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tunjangan Makan', prefixText: 'Rp ', border: OutlineInputBorder()),
                      onChanged: (_) => _calculateTakeHome(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _allowanceTransportController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tunjangan Transportasi', prefixText: 'Rp ', border: OutlineInputBorder()),
                      onChanged: (_) => _calculateTakeHome(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _allowancePositionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tunjangan Jabatan', prefixText: 'Rp ', border: OutlineInputBorder()),
                      onChanged: (_) => _calculateTakeHome(),
                    ),
                    const SizedBox(height: 12),

                    // Potongan BPJS
                    TextField(
                      controller: _deductionBPJSHealthController,
                      enabled: true,
                      decoration: const InputDecoration(labelText: 'Potongan BPJS Kesehatan', prefixText: 'Rp ', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deductionBPJSTKController,
                      enabled: true,
                      decoration: const InputDecoration(labelText: 'Potongan BPJS TK', prefixText: 'Rp ', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),

                    // Take Home Pay
                    TextField(
                      controller: _takeHomePayController,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Take Home Pay', prefixText: 'Rp ', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Simpan Perubahan
                    ElevatedButton(
                      onPressed: _updateEmployee,
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }
} // <--- The closing brace for the class was also missing after the original build method.