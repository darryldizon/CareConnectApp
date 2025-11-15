import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard.dart';
import '../models/user_model.dart';
import 'loading2.dart'; // Import your loading screen

// Sample users list
List<UserModel> users = [
  UserModel(email: 'admin', password: 'admin', role: 'Admin', isApproved: true),
  UserModel(email: 'v', password: '1', role: 'Volunteer', isApproved: true),
  UserModel(email: 'd', password: '1', role: 'Donor', isApproved: true),
  UserModel(email: 'r', password: '1', role: 'Recipient', isApproved: true),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _logoController;
  late AnimationController _bgController;

  late Animation<double> _logoScale;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();

    // 🔹 Logo bounce animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 1.0, end: 1.1)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_logoController);

    // 🔹 Animated gradient background
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFF00B4DB),
      end: const Color(0xFF38EF7D),
    ).animate(_bgController);

    _color2 = ColorTween(
      begin: const Color(0xFF0083B0),
      end: const Color(0xFF11998E),
    ).animate(_bgController);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    UserModel? user = users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => UserModel(email: '', password: '', role: '', isApproved: false),
    );

    if (user.email == '') {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      return;
    }

    if (!user.isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account is waiting for admin approval')),
      );
      return;
    }

    // ✅ Show loading screen before navigating
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(
          nextScreen: user.role == 'Admin'
              ? const AdminDashboard()
              : const DashboardScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _color1.value ?? const Color(0xFF00B4DB),
                  _color2.value ?? const Color(0xFF0083B0),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔹 Animated logo
                        ScaleTransition(
                          scale: _logoScale,
                          child: Image.asset(
                            'assets/images/cc.png',
                            height: 200,
                          ),
                        ),
                        const SizedBox(height: 30),

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
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          child: const Text(
                            'Don’t have an account? Sign Up',
                            style: TextStyle(color: Color(0xFF0083B0)),
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
      },
    );
  }
}
