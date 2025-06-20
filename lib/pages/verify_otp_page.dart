import 'package:flutter/material.dart';
import 'dart:convert';  // Untuk menggunakan json.decode
import 'package:http/http.dart' as http;
import 'set_password_page.dart'; // Pastikan SetPasswordPage sudah diimpor

class VerifyOTPPage extends StatefulWidget {
  final String email;

  const VerifyOTPPage({super.key, required this.email});

  @override
  _VerifyOTPPageState createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<VerifyOTPPage> {
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage; // Definisikan _errorMessage

  // Fungsi untuk memverifikasi OTP
  Future<void> verifyOTP() async {
    String otp = _otpController.text.trim();
    if (otp.isNotEmpty) {
      final String url = 'http://localhost:8080//verifyOTP.php'; // Gantilah dengan URL PHP Anda

      final response = await http.post(
        Uri.parse(url),
        body: {'otp': otp, 'email': widget.email}, // Kirimkan OTP dan email ke backend
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['message'] == 'OTP Verified. Please set your password') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetPasswordPage(email: widget.email),
            ),
          );
        } else {
          setState(() {
            _errorMessage = responseBody['message'] ?? 'Invalid OTP';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'OTP verification failed. Please try again.';
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
            Text('Enter OTP sent to your email', style: TextStyle(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _otpController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'OTP',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: verifyOTP,
              child: Text('Verify OTP'),
            ),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)), // Tampilkan pesan error jika ada
          ],
        ),
      ),
    );
  }
}
