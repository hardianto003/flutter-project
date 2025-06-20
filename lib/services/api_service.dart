import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // sudah ada
import 'package:image_picker/image_picker.dart';

final String baseUrl = 'https://backend_x.is-web.my.id/api/';
// final String baseUrl = 'http://localhost:8000/api/';

class ApiService {
  // Fungsi untuk registrasi
  Future<Map<String, dynamic>> registerUser(
    String username,
    String fullName,
    String email,
    String birthDate,
  ) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }, // URL endpoint API Anda
      body: json.encode({
        'name': username,
        'email': email,
        'full_name': fullName,
        'birth_date': birthDate, // Menambahkan tanggal lahir
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('${baseUrl}user'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  // Fungsi untuk login
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Mengembalikan data JSON dari server
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Fungsi untuk mengirim OTP
  static Future<Map<String, dynamic>> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse('${baseUrl}sendOTP.php'),
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Mengembalikan data JSON
    } else {
      throw Exception('Failed to send OTP');
    }
  }

  // Fungsi untuk verifikasi OTP
  static Future<Map<String, dynamic>> verifyOTP(String otp) async {
    final response = await http.post(
      Uri.parse('${baseUrl}verifyOTP.php'),
      body: {'otp': otp},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Mengembalikan data JSON
    } else {
      throw Exception('Failed to verify OTP');
    }
  }

  static Future<Map<String, dynamic>> uploadPost({
    required String token,
    required String content,
    XFile? imageFile, // opsional, jika ingin upload gambar
  }) async {
    final uri = Uri.parse('${baseUrl}posts');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Content-Type'] = 'multipart/form-data'
          ..headers['Accept'] = 'application/json'
          ..fields['caption'] = content;

    if (imageFile != null) {
      if (kIsWeb) {
        // Untuk web, gunakan fromBytes
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
        );
      } else {
        // Untuk mobile/desktop, gunakan fromPath
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to upload post: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<List<dynamic>> getAllPosts(String token) async {
    final response = await http.get(
      Uri.parse('${baseUrl}posts'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch posts: ${response.statusCode}');
    }
  }
}
