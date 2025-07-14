import 'package:flutter/material.dart';
import 'package:kasirku/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' show AuthException;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  void _togglePassword() => setState(() => _obscurePass = !_obscurePass);
  void _toggleConfirm() => setState(() => _obscureConfirm = !_obscureConfirm);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_password.text != _confirm.text) {
      _showMessage("Password tidak cocok");
      return;
    }

    try {
      final response = await SupabaseService().signUp(
        _email.text.trim(),
        _password.text,
      );
      if (response.user != null) {
        _showMessage("Registrasi berhasil! Cek email untuk verifikasi.");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showMessage("Registrasi gagal.");
      }
    } on AuthException catch (e) {
      _showMessage("Error: ${e.message}");
    } catch (e) {
      _showMessage("Terjadi kesalahan: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText:
            isPassword ? (isConfirm ? _obscureConfirm : _obscurePass) : false,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Wajib diisi';
          if (!isPassword && !value.contains('@')) return 'Email tidak valid';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      (isConfirm ? _obscureConfirm : _obscurePass)
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: isConfirm ? _toggleConfirm : _togglePassword,
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'DAFTAR',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  _buildInput('Email', _email, Icons.email),
                  _buildInput(
                    'Password',
                    _password,
                    Icons.lock,
                    isPassword: true,
                  ),
                  _buildInput(
                    'Konfirmasi Password',
                    _confirm,
                    Icons.lock_outline,
                    isPassword: true,
                    isConfirm: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'DAFTAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
