import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../models/help_post_model.dart';

// -------------------------------------------------------
//  Fade + Slide Animation Widget
// -------------------------------------------------------
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

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(curved);
    _fade = Tween<double>(begin: 0, end: 1).animate(curved);

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

// -------------------------------------------------------
//  MAIN DASHBOARD SCREEN
// -------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final _descController = TextEditingController();
  final _locController = TextEditingController();

  String _selectedType = 'Request';
  String _selectedCategory = 'Food';
  String searchQuery = '';
  String filterType = 'All';

  bool _showSearch = false;
  bool _showPostPanel = false;

  // 🔐 Prevent multiple likes per post
  final Set<int> likedPosts = {};

  late AnimationController _panelController;

  final List<HelpPost> _posts = [
    HelpPost(
      type: 'Request',
      category: 'Food',
      description: 'Need food supplies for Hiway families',
      location: 'Hiway',
      user: 'Alice',
      likes: 5,
      comments: ['Sending help!', 'I’ll donate rice'],
      isPinned: true,
    ),
    HelpPost(
      type: 'Offer',
      category: 'Medicine',
      description: 'Offering free vitamins near Hiway Clinic',
      location: 'Hiway',
      user: 'Bob',
      likes: 3,
      comments: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _panelController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  //  AppBar Actions
  // -------------------------------------------------------
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(
          name: 'Demo User',
          role: 'Volunteer',
          contact: '09123456789',
        ),
      ),
    );
  }

  void _toggleSearch() => setState(() {
        _showSearch = !_showSearch;
        _showPostPanel = false;
      });

  void _togglePostPanel() => setState(() {
        _showPostPanel = !_showPostPanel;
        _showSearch = false;
      });

  // -------------------------------------------------------
  //  Create a Post
  // -------------------------------------------------------
  void _addPost() {
    if (_descController.text.isEmpty || _locController.text.isEmpty) return;

    setState(() {
      _posts.insert(
        0,
        HelpPost(
          type: _selectedType,
          category: _selectedCategory,
          description: _descController.text,
          location: _locController.text,
          user: 'Demo User',
        ),
      );
      _descController.clear();
      _locController.clear();
      _showPostPanel = false;
    });
  }

  // -------------------------------------------------------
  //  Post Actions (Like + Comment)
  // -------------------------------------------------------
  void _likePost(int index) {
    if (likedPosts.contains(index)) return; // ❌ Prevent double-like
    setState(() {
      likedPosts.add(index);
      _posts[index].likes++;
    });
  }

  void _addComment(int index, String comment) {
    if (comment.isEmpty) return;
    setState(() => _posts[index].comments.add(comment));
  }

  // -------------------------------------------------------
  //  Post Filtering
  // -------------------------------------------------------
  List<HelpPost> get filteredPosts {
    List<HelpPost> fp = _posts;

    if (searchQuery.isNotEmpty) {
      fp = fp
          .where((p) =>
              p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (filterType != 'All') {
      fp = fp.where((p) => p.type == filterType).toList();
    }

    return fp;
  }

  // -------------------------------------------------------
  //  UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FF),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF0083B0),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _toggleSearch),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _togglePostPanel),
          IconButton(icon: const Icon(Icons.person), onPressed: () => _openProfile(context)),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
        ],
      ),

      body: Stack(
        children: [
          // -------------------------------------------------------
          //  Posts Feed with FadeSlide Animation
          // -------------------------------------------------------
          ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 140),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];

              return FadeSlide(
                delay: index * 120,
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE
                        Text('${post.user} • ${post.type}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),

                        const SizedBox(height: 4),
                        Text('Category: ${post.category}',
                            style: TextStyle(color: Colors.grey[600])),

                        const SizedBox(height: 6),
                        Text(post.description,
                            style: const TextStyle(fontSize: 15)),

                        const SizedBox(height: 6),
                        Text('📍 ${post.location}',
                            style: TextStyle(color: Colors.grey[700])),

                        const Divider(height: 22),

                        // LIKE + COMMENT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: likedPosts.contains(index)
                                  ? null
                                  : () => _likePost(index),
                              icon: Icon(
                                likedPosts.contains(index)
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                color: likedPosts.contains(index)
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                              label: Text('Like (${post.likes})'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final c = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Add Comment'),
                                    content: TextField(
                                      controller: c,
                                      decoration: const InputDecoration(
                                          labelText: 'Your comment'),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () {
                                          _addComment(index, c.text);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Post'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.comment_outlined),
                              label: Text('Comment (${post.comments.length})'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // -------------------------------------------------------
          //  🔍 Search Panel (Animated)
          // -------------------------------------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            top: _showSearch ? 0 : -200,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search posts...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: filterType,
                    dropdownColor: Colors.black87,
                    items: ['All', 'Request', 'Offer']
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (val) => setState(() => filterType = val!),
                  ),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------
          //  📝 Post Creation Panel (Animated Bottom Sheet)
          // -------------------------------------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            bottom: _showPostPanel ? 0 : -420,
            left: 0,
            right: 0,
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -3),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const Text('Create a Post',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Dropdowns
                  DropdownButton<String>(
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'Request', child: Text('Request Help')),
                      DropdownMenuItem(value: 'Offer', child: Text('Offer Help')),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: const [
                      DropdownMenuItem(value: 'Food', child: Text('Food')),
                      DropdownMenuItem(value: 'Shelter', child: Text('Shelter')),
                      DropdownMenuItem(value: 'Medicine', child: Text('Medicine')),
                      DropdownMenuItem(value: 'Supplies', child: Text('Supplies')),
                      DropdownMenuItem(value: 'Volunteer', child: Text('Volunteer')),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),

                  // Text Fields
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                        labelText: 'What do you need or offer?',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locController,
                    decoration: const InputDecoration(
                        labelText: 'Location', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _addPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0083B0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Post',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
