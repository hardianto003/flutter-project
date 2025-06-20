import 'package:flutter/material.dart';
import 'dart:convert';  // Untuk menggunakan json.decode
import 'package:http/http.dart' as http;
import 'login_page.dart'; // Pastikan LoginPage sudah diimpor

class SetPasswordPage extends StatefulWidget {
  final String email;

  const SetPasswordPage({super.key, required this.email});

  @override
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // Definisikan _errorMessage

  // Fungsi untuk mengatur password setelah verifikasi OTP
  Future<void> setPassword() async {
    String password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      final String url = 'http://localhost:8080//setPassword.php'; // Gantilah dengan URL PHP Anda

      final response = await http.post(
        Uri.parse(url),
        body: {'email': widget.email, 'password': password}, // Kirimkan email dan password ke backend
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['message'] == 'Password has been set successfully') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()), // Navigasi ke LoginPage setelah password berhasil diatur
          );
        } else {
          setState(() {
            _errorMessage = responseBody['message'] ?? 'Failed to set password';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to set password. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Set your new password', style: TextStyle(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: setPassword,
              child: Text('Set Password'),
            ),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)), // Tampilkan pesan error jika ada
          ],
        ),
      ),
    );
  }
}
