import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
        return;
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil')));
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Registrasi gagal')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
          const SizedBox(height: 5),
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
              contentPadding: const EdgeInsets.symmetric(
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
                    'REGISTER BARU',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 20),
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
                      child: const Text(
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
