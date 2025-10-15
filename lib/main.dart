import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'screens/create_employee.dart';
import 'screens/manage_employee.dart';

void main() async {
  // Pastikan binding Flutter sudah siap sebelum async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database (tidak mengganggu UI)
  await DatabaseHelper.instance.database;

  runApp(const HRAppDesktop());
}

class HRAppDesktop extends StatelessWidget {
  const HRAppDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR App Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi HR Desktop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person_add_alt_1), text: 'Create Data Karyawan'),
            Tab(icon: Icon(Icons.manage_accounts), text: 'Manajemen Data'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CreateEmployeeScreen(),
          ManageEmployeeScreen(),
        ],
      ),
    );
  }
}
