import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController(text: "arum_sari");
  final TextEditingController emailController = TextEditingController(text: "arum@gmail.com");
  final TextEditingController editProfileController = TextEditingController();
  final TextEditingController editPasswordController = TextEditingController();

  String displayName = "Arum Sari";
  String displayPassword = "";

  void _saveChanges() {
    setState(() {
      if (editProfileController.text.isNotEmpty) {
        displayName = editProfileController.text;
      }
      if (editPasswordController.text.isNotEmpty) {
        displayPassword = editPasswordController.text;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perubahan berhasil disimpan")),
    );

    editProfileController.clear();
    editPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("back", style: TextStyle(color: Colors.blue)),
        ),
        title: const Text("Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.blue),
            onPressed: () {
              // Tambahkan aksi delete jika diperlukan
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple.shade100,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : "A",
                    style: const TextStyle(fontSize: 40, color: Colors.black),
                  ),
                ),
                Positioned(
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 16, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: "username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: "email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: editProfileController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.edit),
                labelText: "edit profil (nama)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: editPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: "edit password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.check),
              label: const Text("Simpan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade100,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
