import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'register_page.dart';
import '../main.dart'; // Import untuk XHomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController =
      TextEditingController(); // Menggunakan password controller
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // Show/Hide password feature

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose(); // Dispose password controller
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = "Phone, email, or username is required");
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Password is required");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response['token'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login Successful!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', response['token']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => XHomePage()),
          );
        }
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _errorMessage = "Connection error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive calculations
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth <= 600;

    final containerWidth =
        isTablet
            ? (screenWidth > 1200 ? 600.0 : screenWidth * 0.5)
            : screenWidth * 0.9;

    final horizontalPadding = isTablet ? 80.0 : 32.0;
    final titleFontSize = isTablet ? 31.0 : 28.0;
    final buttonHeight = isTablet ? 40.0 : 44.0;
    final inputHeight = isTablet ? 56.0 : 52.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          // Menambahkan SingleChildScrollView untuk menangani overflow
          child: Column(
            children: [
              // Main content area
              Center(
                child: Container(
                  width: containerWidth,
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    minHeight: screenHeight * 0.8,
                  ),
                  child: Column(
                    children: [
                      // Header with close button and logo
                      SizedBox(
                        height: 56,
                        child: Stack(
                          children: [
                            // Close button
                            Positioned(
                              top: 12,
                              left: isMobile ? 8 : 16,
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

                            // X Logo
                            Positioned(
                              top: 12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text(
                                  '𝕎',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 30 : 26,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main content
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isTablet ? 20 : 16),

                            // Title
                            Text(
                              'Sign in to X',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: isTablet ? 32 : 24),

                            // Error message
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

                            // Google Sign in button
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Google login not implemented yet",
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      buttonHeight / 2,
                                    ),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Profile icon (purple circle with 'p')
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF8B5CF6,
                                        ), // Purple color
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'p',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),

                                    // Sign in text
                                    Text(
                                      'Sign in as putri',
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 4),

                                    // Email text
                                    Flexible(
                                      child: Text(
                                        'putriichaerunnisa889@gmail.com',
                                        style: TextStyle(
                                          fontSize: isMobile ? 12 : 13,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF5F6368),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),

                                    // Google logo dari assets
                                    Image.asset(
                                      'assets/image/google.png',
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),

                            // Apple Sign in button
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Apple login not implemented yet",
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      buttonHeight / 2,
                                    ),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.apple,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Sign in with Apple',
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Divider with "or"
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Color(0xFF2F3336),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Color(0xFF2F3336),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Phone/Email/Username input
                            Container(
                              height: inputHeight,
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
                                  fontSize: isMobile ? 16 : 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Phone, email, or username',
                                  labelStyle: TextStyle(
                                    color:
                                        _emailController.text.isNotEmpty
                                            ? Color(0xFF1D9BF0)
                                            : Color(0xFF71767B),
                                    fontSize: isMobile ? 16 : 17,
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
                            SizedBox(height: 20),

                            // Password input
                            Container(
                              height: inputHeight,
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
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 16 : 17,
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
                                    fontSize: isMobile ? 16 : 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    16,
                                    48,
                                    8,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Color(0xFF71767B),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Next button
                            SizedBox(
                              width: double.infinity,
                              height: isTablet ? 36 : 40,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 18 : 20,
                                    ),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child:
                                    _isLoading
                                        ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.black,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          'Sign in',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0,
                                          ),
                                        ),
                              ),
                            ),
                            SizedBox(height: 12),

                            // Forgot password button
                            SizedBox(
                              width: double.infinity,
                              height: isTablet ? 36 : 40,
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Forgot password not implemented yet",
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Color(0xFF536471),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 18 : 20,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),

                            // Spacer untuk mendorong content ke bawah
                            SizedBox(height: 24),

                            // Sign up link
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Color(0xFF71767B),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: Color(0xFF1D9BF0),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isTablet ? 40 : 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isMobile ? 8 : 12,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: isMobile ? 12 : 16,
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
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
