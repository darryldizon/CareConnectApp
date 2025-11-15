import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String role;
  final String contact;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.role,
    required this.contact,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  String _selectedRole = 'Volunteer';
  bool _darkMode = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Alignment _beginAlignment;
  late Alignment _endAlignment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _contactController = TextEditingController(text: widget.contact);
    _selectedRole = widget.role;

    // 🌀 Profile image bounce animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 💠 Animated gradient positions
    _beginAlignment = Alignment.topLeft;
    _endAlignment = Alignment.bottomRight;

    Future.delayed(const Duration(milliseconds: 500), _animateGradient);
  }

  void _animateGradient() {
    setState(() {
      _beginAlignment = _beginAlignment == Alignment.topLeft
          ? Alignment.bottomRight
          : Alignment.topLeft;
      _endAlignment = _endAlignment == Alignment.bottomRight
          ? Alignment.topLeft
          : Alignment.bottomRight;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 5),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _darkMode
              ? [Colors.black87, Colors.grey.shade800]
              : const [Color(0xFF00B4DB), Color(0xFF0083B0)],
          begin: _beginAlignment,
          end: _endAlignment,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌀 Animated avatar
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF00B4DB),
                      child: const Icon(Icons.person,
                          size: 60, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✏️ Name field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF0083B0)),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ☎️ Contact field
                  TextField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      labelText: 'Contact',
                      prefixIcon:
                          const Icon(Icons.phone, color: Color(0xFF0083B0)),
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
                      onChanged: (val) => setState(() => _selectedRole = val!),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🌙 Dark mode toggle
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    activeColor: const Color(0xFF0083B0),
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                  ),
                  const SizedBox(height: 16),

                  // 🔵 Gradient Save button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Profile saved successfully!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
