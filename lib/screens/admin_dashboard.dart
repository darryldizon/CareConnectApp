import 'package:flutter/material.dart';
import '../models/help_post_model.dart';
import 'login_screen.dart';

// =====================================================
// ANIMATION WIDGET
// =====================================================
class FadeSlide extends StatefulWidget {
  final Widget child;
  final int delay;

  const FadeSlide({super.key, required this.child, this.delay = 100});

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(curve);

    _fade = Tween<double>(begin: 0, end: 1).animate(curve);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// =====================================================
// MAIN ADMIN DASHBOARD
// =====================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Sample posts
  final List<HelpPost> _posts = [
    HelpPost(
      type: 'Request',
      category: 'Food',
      description: 'Need 10 food packs',
      location: 'Barangay 1',
      user: 'Alice',
      isVerified: false,
      likes: 2,
      comments: ['I can help'],
    ),
    HelpPost(
      type: 'Offer',
      category: 'Medicine',
      description: 'Volunteer for medicine delivery',
      location: 'Barangay 2',
      user: 'Bob',
      isVerified: true,
    ),
  ];

  // Dummy users
  final List<_User> users = [
    _User(email: "juan@example.com", role: "User", isApproved: false),
    _User(email: "maria@example.com", role: "User", isApproved: false),
    _User(email: "admin@example.com", role: "Admin", isApproved: true),
  ];

  void _approvePost(int index) {
    setState(() => _posts[index].isVerified = true);
  }

  void _rejectPost(int index) {
    setState(() => _posts.removeAt(index));
  }

  Map<String, int> _calculateCategoryStats() {
    Map<String, int> stats = {};
    for (var post in _posts) {
      stats[post.category] = (stats[post.category] ?? 0) + 1;
    }
    return stats;
  }

  int _totalLikes() =>
      _posts.fold(0, (sum, post) => sum + post.likes);

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateCategoryStats();

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =====================================================
            // STATISTICS CARD
            // =====================================================
            FadeSlide(
              delay: 150,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📊 Dashboard Statistics",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statBox("Total Posts", _posts.length.toString(),
                              Icons.article),
                          _statBox("Total Likes", _totalLikes().toString(),
                              Icons.favorite),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Text("Categories:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      ...stats.entries
                          .map((e) => Text("• ${e.key}: ${e.value}")),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // POSTS
            // =====================================================
            const Text("📝 Help Posts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ..._posts.asMap().entries.map((entry) {
              int index = entry.key;
              HelpPost post = entry.value;

              return FadeSlide(
                delay: 200 + index * 120,
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                        "${post.user} • ${post.type} (${post.category})"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.description),
                        Text("📍 ${post.location}"),
                        Text("Verified: "
                            "${post.isVerified ? "✔ Approved" : "❌ Pending"}"),
                        Text("Likes: ${post.likes}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!post.isVerified)
                          IconButton(
                            onPressed: () => _approvePost(index),
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                          ),
                        IconButton(
                          onPressed: () => _rejectPost(index),
                          icon: const Icon(Icons.cancel, color: Colors.red),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 25),

            // =====================================================
            // PENDING USERS SECTION
            // =====================================================
            const Text("👥 Pending User Approvals",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...users
                .where((u) => !u.isApproved && u.role != 'Admin')
                .toList()
                .asMap()
                .entries
                .map((entry) {
              int i = entry.key;
              _User u = entry.value;

              return FadeSlide(
                delay: 250 + i * 120,
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(u.email),
                    subtitle: Text("Role: ${u.role}"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        setState(() => u.isApproved = true);
                      },
                      child: const Text("Approve"),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // STAT BOX WIDGET
  // =====================================================
  Widget _statBox(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

// SIMPLE USER MODEL
class _User {
  String email;
  String role;
  bool isApproved;

  _User({required this.email, required this.role, required this.isApproved});
}
