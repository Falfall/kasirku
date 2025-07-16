import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool obscurePassword = true;
  File? _image;

  final TextEditingController nameController = TextEditingController(
    text: "Nama Kasir",
  );
  final TextEditingController emailController = TextEditingController(
    text: "kasir@email.com",
  );
  final TextEditingController usernameController = TextEditingController(
    text: "kasir01",
  );
  final TextEditingController passwordController = TextEditingController(
    text: "password123",
  );

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Kasir")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditing ? _pickImage : null,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _image != null
                            ? FileImage(_image!)
                            : const AssetImage('assets/profile.jpg')
                                as ImageProvider,
                  ),
                  if (isEditing)
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              enabled: isEditing,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: isEditing,
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              enabled: isEditing,
            ),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
              enabled: isEditing,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  child: Text(isEditing ? "Batal" : "Edit"),
                ),
                if (isEditing)
                  ElevatedButton(
                    onPressed: () {
                      // Simpan perubahan
                      setState(() {
                        isEditing = false;
                      });
                    },
                    child: const Text("Simpan"),
                  ),
                ElevatedButton(
                  onPressed: () {
                    // Hapus data atau logout
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Hapus"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
