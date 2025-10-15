import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:file_picker/file_picker.dart';
import '../models/employee_model.dart';
import '../db/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';

class ManageEmployeeScreen extends StatefulWidget {
  const ManageEmployeeScreen({super.key});

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

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
      _salaryBasicController.text = employee.salaryBasic.toString();
      _allowanceHouseController.text = employee.allowanceHouse.toString();
      _allowanceMealController.text = employee.allowanceMeal.toString();
      _allowanceTransportController.text = employee.allowanceTransport.toString();
      _allowancePositionController.text = employee.allowancePosition.toString();
      _deductionBPJSHealthController.text = employee.deductionBPJSHealth.toString();
      _deductionBPJSTKController.text = employee.deductionBPJSTK.toString();
      _takeHomePayController.text = employee.takeHomePay.toString();
      _photoPath = employee.photoPath;
    });
  }

  // 🔹 Fungsi untuk hitung otomatis TakeHomePay
  void _calculateTakeHome() {
    double salary = double.tryParse(_salaryBasicController.text) ?? 0;
    double house = double.tryParse(_allowanceHouseController.text) ?? 0;
    double meal = double.tryParse(_allowanceMealController.text) ?? 0;
    double transport = double.tryParse(_allowanceTransportController.text) ?? 0;
    double position = double.tryParse(_allowancePositionController.text) ?? 0;
    double bpjsHealth = double.tryParse(_allowanceTransportController.text) ?? 0;
    double bpjsTK = double.tryParse(_allowancePositionController.text) ?? 0;

    // double bpjsHealth = salary * 0.05;
    // double bpjsTK = salary * 0.03;

    // _deductionBPJSHealthController.text = bpjsHealth.toStringAsFixed(0);
    // _deductionBPJSTKController.text = bpjsTK.toStringAsFixed(0);

    double takeHome = salary + house + meal + transport + position - (bpjsHealth + bpjsTK);

    _takeHomePayController.text = takeHome.toStringAsFixed(0);
  }

  // 🔹 Fungsi simpan perubahan (update)
  Future<void> _updateEmployee() async {
    if (_selectedEmployee == null) return;

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
      salaryBasic: double.tryParse(_salaryBasicController.text) ?? 0.0,
      allowanceHouse: double.tryParse(_allowanceHouseController.text) ?? 0.0,
      allowanceMeal: double.tryParse(_allowanceMealController.text) ?? 0.0,
      allowanceTransport: double.tryParse(_allowanceTransportController.text) ?? 0.0,
      allowancePosition: double.tryParse(_allowancePositionController.text) ?? 0.0,
      deductionBPJSHealth: double.tryParse(_deductionBPJSHealthController.text) ?? 0.0,
      deductionBPJSTK: double.tryParse(_deductionBPJSTKController.text) ?? 0.0,
      takeHomePay: double.tryParse(_takeHomePayController.text) ?? 0.0,
      photoPath: _photoPath ?? '',
    );

    await DatabaseHelper.instance.updateEmployee(updatedEmployee);
    await _fetchEmployees();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data karyawan berhasil diperbarui!')),
    );
    setState(() {
      _isEditing = false;
    });
  }

  // 🔹 Fungsi hapus karyawan
  Future<void> _deleteEmployee() async {
    if (_selectedEmployee == null) return;

    await DatabaseHelper.instance.deleteEmployee(_selectedEmployee!.id);
    await _fetchEmployees();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data karyawan berhasil dihapus!')),
    );

    setState(() {
      _selectedEmployee = null;
      _isEditing = false;
      _clearForm();
    });
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
                    _photoFile != null
                        ? Image.file(_photoFile!, width: 150, height: 150, fit: BoxFit.cover)
                        : _photoPath != null && _photoPath!.isNotEmpty
                            ? Image.file(File(_photoPath!), width: 150, height: 150, fit: BoxFit.cover)
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
                      enabled: false,
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
                      enabled: false,
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
                      enabled: false,
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
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Potongan BPJS Kesehatan', prefixText: 'Rp ', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deductionBPJSTKController,
                      enabled: false,
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