import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Password tidak cocok')));
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = _emailController.text;
      String password = _passwordController.text;

      // Simpan akun ke shared preferences
      await prefs.setString('user_$email', password);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registrasi berhasil')));

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    bool isConfirmPassword = controller == _confirmPasswordController;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText:
                isPassword
                    ? (isConfirmPassword
                        ? _obscureConfirmPassword
                        : _obscurePassword)
                    : false,
            keyboardType: inputType,
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          (isConfirmPassword
                                  ? _obscureConfirmPassword
                                  : _obscurePassword)
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            isConfirmPassword
                                ? _toggleConfirmPasswordVisibility
                                : _togglePasswordVisibility,
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(20),
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
                  Text(
                    'REGISTER BARU',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildInputField(
                    label: 'Email atau username',
                    controller: _emailController,
                    icon: Icons.person,
                  ),
                  _buildInputField(
                    label: 'Password',
                    controller: _passwordController,
                    icon: Icons.vpn_key,
                    isPassword: true,
                  ),
                  _buildInputField(
                    label: 'Konfirmasi Password',
                    controller: _confirmPasswordController,
                    icon: Icons.vpn_key,
                    isPassword: true,
                  ),
                  _buildInputField(
                    label: 'Nomor Handphone',
                    controller: _phoneController,
                    icon: Icons.phone,
                    inputType: TextInputType.phone,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'DAFTAR',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
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
