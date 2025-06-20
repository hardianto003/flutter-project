import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:x/pages/login_page.dart';
import '../services/api_service.dart'; // Impor dari api_service
import 'verify_otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Dropdown values for Date of Birth
  String? _selectedMonth;
  String? _selectedDay;
  String? _selectedYear;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengirim OTP ke email
  String? _getBirthDate() {
    if (_selectedMonth != null &&
        _selectedDay != null &&
        _selectedYear != null) {
      int monthIndex = int.parse(_selectedMonth!); // Convert month to integer
      String formattedMonth = monthIndex.toString().padLeft(2, '0');
      String formattedDay = _selectedDay!.padLeft(2, '0');
      return "$_selectedYear-$formattedMonth-$formattedDay"; // Format YYYY-MM-DD
    }
    return null;
  }

  // Fungsi untuk membuat akun
  Future<void> _createAccount() async {
    String email = _emailController.text.trim();
    String? birthDate = _getBirthDate();

    if (_nameController.text.isEmpty) {
      setState(() => _errorMessage = "Username is required");
      return;
    }
    if (_fullNameController.text.isEmpty) {
      setState(() => _errorMessage = "Full name is required");
      return;
    }
    if (email.isEmpty) {
      setState(() => _errorMessage = "Email is required");
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Password is required");
      return;
    }
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = "Confirm password is required");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }
    if (birthDate == null) {
      setState(() => _errorMessage = "Date of birth is required");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.registerUser(
        _nameController.text.trim(),
        _fullNameController.text.trim(),
        email,
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
        birthDate, // Pastikan ApiService menerima fullName
      );

      if (response['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // alihkan ke halama login
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
        // sendOTP(email);
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to register user';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 600,
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Header
                    SizedBox(
                      height: 56,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 12,
                            left: 16,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                '𝕏',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'Create your account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 32),
                            // Error Message
                            if (_errorMessage != null)
                              Container(
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            // Input Name
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _nameController.text.isNotEmpty
                                          ? Color(0xFF1D9BF0)
                                          : Color(0xFF333639),
                                  width:
                                      _nameController.text.isNotEmpty ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _nameController,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLength: 50,
                                onChanged: (value) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    color:
                                        _nameController.text.isNotEmpty
                                            ? Color(0xFF1D9BF0)
                                            : Color(0xFF71767B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    16,
                                    50,
                                    8,
                                  ),
                                  counterText: '',
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            // Input Full Name
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _fullNameController.text.isNotEmpty
                                          ? Color(0xFF1D9BF0)
                                          : Color(0xFF333639),
                                  width:
                                      _fullNameController.text.isNotEmpty
                                          ? 2
                                          : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _fullNameController,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLength: 50,
                                onChanged: (value) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: TextStyle(
                                    color:
                                        _fullNameController.text.isNotEmpty
                                            ? Color(0xFF1D9BF0)
                                            : Color(0xFF71767B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    16,
                                    50,
                                    8,
                                  ),
                                  counterText: '',
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            // Input Email
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _emailController.text.isNotEmpty
                                          ? Color(0xFF1D9BF0)
                                          : Color(0xFF333639),
                                  width:
                                      _emailController.text.isNotEmpty ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color:
                                        _emailController.text.isNotEmpty
                                            ? Color(0xFF1D9BF0)
                                            : Color(0xFF71767B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    16,
                                    12,
                                    8,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            // Input Password
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _passwordController.text.isNotEmpty
                                          ? Color(0xFF1D9BF0)
                                          : Color(0xFF333639),
                                  width:
                                      _passwordController.text.isNotEmpty
                                          ? 2
                                          : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color:
                                        _passwordController.text.isNotEmpty
                                            ? Color(0xFF1D9BF0)
                                            : Color(0xFF71767B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    16,
                                    12,
                                    8,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            // Input Confirm Password
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _confirmPasswordController.text.isNotEmpty
                                          ? Color(0xFF1D9BF0)
                                          : Color(0xFF333639),
                                  width:
                                      _confirmPasswordController.text.isNotEmpty
                                          ? 2
                                          : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(
                                    color:
                                        _confirmPasswordController
                                                .text
                                                .isNotEmpty
                                            ? Color(0xFF1D9BF0)
                                            : Color(0xFF71767B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    16,
                                    12,
                                    8,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                            // Date of Birth section
                            Text(
                              'Date of birth',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'This will not be shown publicly. Confirm your own age, even if this account is for a business, a pet, or something else.',
                              style: TextStyle(
                                color: Color(0xFF71767B),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: 20),
                            // Date of birth dropdowns
                            Row(
                              children: [
                                // Month dropdown
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF333639),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedMonth,
                                      dropdownColor: Color(0xFF16181C),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF71767B),
                                        size: 20,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.fromLTRB(
                                          12,
                                          16,
                                          8,
                                          8,
                                        ),
                                      ),
                                      items: [
                                        for (var month in [
                                          "January",
                                          "February",
                                          "March",
                                          "April",
                                          "May",
                                          "June",
                                          "July",
                                          "August",
                                          "September",
                                          "October",
                                          "November",
                                          "December",
                                        ])
                                          DropdownMenuItem<String>(
                                            value:
                                                (month) == "January"
                                                    ? "1"
                                                    : (month) == "February"
                                                    ? "2"
                                                    : (month) == "March"
                                                    ? "3"
                                                    : (month) == "April"
                                                    ? "4"
                                                    : (month) == "May"
                                                    ? "5"
                                                    : (month) == "June"
                                                    ? "6"
                                                    : (month) == "July"
                                                    ? "7"
                                                    : (month) == "August"
                                                    ? "8"
                                                    : (month) == "September"
                                                    ? "9"
                                                    : (month) == "October"
                                                    ? "10"
                                                    : (month) == "November"
                                                    ? "11"
                                                    : "12",
                                            child: Text(
                                              month,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedMonth = value;
                                          _errorMessage = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Day dropdown
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF333639),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedDay,
                                      dropdownColor: Color(0xFF16181C),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF71767B),
                                        size: 20,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.fromLTRB(
                                          12,
                                          16,
                                          8,
                                          8,
                                        ),
                                      ),
                                      items: List.generate(31, (index) {
                                        return DropdownMenuItem<String>(
                                          value: (index + 1).toString(),
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        );
                                      }),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDay = value;
                                          _errorMessage = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Year dropdown
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF333639),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedYear,
                                      dropdownColor: Color(0xFF16181C),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF71767B),
                                        size: 20,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.fromLTRB(
                                          12,
                                          16,
                                          8,
                                          8,
                                        ),
                                      ),
                                      items: List.generate(100, (index) {
                                        return DropdownMenuItem<String>(
                                          value:
                                              (DateTime.now().year - index)
                                                  .toString(),
                                          child: Text(
                                            (DateTime.now().year - index)
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        );
                                      }),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedYear = value;
                                          _errorMessage = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            // Tombol Next
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _createAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child:
                                    _isLoading
                                        ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.black,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0,
                                          ),
                                        ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer (sejajar di luar kotak)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Color(0xFF121212),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children:
                  [
                        'About',
                        'Get the X app',
                        'Get the Grok app',
                        'Careers',
                        'Terms of Service',
                        'Privacy Policy',
                        'Cookie Policy',
                        'Developers',
                        'Advertising',
                        'Settings',
                        '© 2025 X Corp.',
                      ]
                      .map(
                        (text) => Text(
                          text,
                          style: TextStyle(
                            color: Color(0xFF71767B),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
