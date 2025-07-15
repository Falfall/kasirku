import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('logged_in_user') ?? '';
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user');
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onMenuSelected(String value) {
    if (value == 'barangmasuk') {
      Navigator.pushNamed(context, '/barangmasuk');
    } else if (value == 'barangkeluar') {
      Navigator.pushNamed(context, '/barangkeluar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: _onMenuSelected,
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'barangmasuk',
                    child: Text('Barang Masuk'),
                  ),
                  PopupMenuItem(
                    value: 'barangkeluar',
                    child: Text('Barang Keluar'),
                  ),
                ],
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Center(
        child: Text(
          'Selamat datang, $_userEmail!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
