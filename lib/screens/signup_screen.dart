import 'package:flutter/material.dart';
import '../models/global_data.dart';
import '../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Volunteer';

  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 🔹 Logo bounce animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_logoController);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    users.add(UserModel(
      email: email,
      password: password,
      role: _selectedRole,
      isApproved: false,
    ));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Account created. Waiting for admin approval.')));

    Navigator.pop(context);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 💠 Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🌀 Animated logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/images/cc.png',
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✉️ Email field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF0083B0)),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔒 Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF0083B0)),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 👥 Role dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: const Color(0xFF0083B0),
                        items: const [
                          DropdownMenuItem(
                              value: 'Volunteer', child: Text('Volunteer')),
                          DropdownMenuItem(value: 'Donor', child: Text('Donor')),
                          DropdownMenuItem(
                              value: 'Recipient', child: Text('Recipient')),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedRole = val!),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔵 Gradient Sign Up button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
