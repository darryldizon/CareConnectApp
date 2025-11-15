import 'package:flutter/material.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  final Widget nextScreen; // Screen to navigate after loading
  const LoadingScreen({super.key, required this.nextScreen});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;   // Logo fade & scale
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScale;

  late AnimationController _bgController; // Background gradient animation
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();

    // 🎬 Logo animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _logoScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 💠 Background gradient animation controller
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFF00B4DB), // Cyan Blue
      end: const Color(0xFF38EF7D),   // Green
    ).animate(_bgController);

    _color2 = ColorTween(
      begin: const Color(0xFF0083B0), // Deep Blue
      end: const Color(0xFF11998E),   // Teal Green
    ).animate(_bgController);

    // ⏳ Navigate to next screen after delay
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.nextScreen),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/cc.png', // Your logo
                        height: 300,
                      ),
                      const SizedBox(height: 30),
                      
                    ],
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
