import 'package:flutter/material.dart';
import '../models/help_post_model.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with SingleTickerProviderStateMixin {
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  String _selectedType = 'Request';
  String _selectedCategory = 'Food';
  String searchQuery = '';
  String filterType = 'All';
  bool _showPostForm = false;

  // Animation controller for smooth expand
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<HelpPost> _posts = [
    HelpPost(
      type: 'Request',
      category: 'Food',
      description: 'Need 10 food packs for families',
      location: 'Barangay 1',
      user: 'Alice',
      likes: 3,
      comments: ['I can help!', 'Count me in'],
      isPinned: true,
    ),
    HelpPost(
      type: 'Offer',
      category: 'Medicine',
      description: 'Can volunteer for medicine delivery',
      location: 'Barangay 2',
      user: 'Bob',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePostForm() {
    setState(() {
      _showPostForm = !_showPostForm;
      _showPostForm ? _controller.forward() : _controller.reverse();
    });
  }

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
      _showPostForm = false;
      _controller.reverse();
    });
  }

  void _likePost(int index) {
    setState(() => _posts[index].likes++);
  }

  void _addComment(int index, String comment) {
    setState(() => _posts[index].comments.add(comment));
  }

  void _replyToComment(int postIndex, int commentIndex, String reply) {
    setState(() {
      _posts[postIndex].comments[commentIndex] += ' ↳ $reply';
    });
  }

  void _reportPost(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reported: "${_posts[index].description}"')),
    );
  }

  List<HelpPost> get filteredPosts {
    List<HelpPost> filtered = _posts;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (filterType != 'All') {
      filtered = filtered.where((p) => p.type == filterType).toList();
    }

    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          // Posts List
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${post.user} • ${post.type} Help',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              onPressed: () => _reportPost(index),
                              icon: const Icon(Icons.report, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Category: ${post.category}',
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(post.description),
                        const SizedBox(height: 4),
                        Text('Location: ${post.location}',
                            style: const TextStyle(color: Colors.grey)),
                        if (post.isPinned)
                          const Text('📌 Pinned Post',
                              style: TextStyle(color: Colors.orange)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              onPressed: () => _likePost(index),
                              icon: const Icon(Icons.thumb_up_alt_outlined),
                              label: Text('Like (${post.likes})'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final controller = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Add Comment'),
                                    content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                            hintText: 'Type a comment...')),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            _addComment(index, controller.text);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Post')),
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
                );
              },
            ),
          ),

          // Animated Post Form
          Align(
            alignment: Alignment.bottomCenter,
            child: SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, -2))
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('Create a Post',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: _selectedType,
                        items: const [
                          DropdownMenuItem(value: 'Request', child: Text('Request Help')),
                          DropdownMenuItem(value: 'Offer', child: Text('Offer Help')),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedType = val!),
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
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _addPost,
                        icon: const Icon(Icons.send),
                        label: const Text('Post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Toggle Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: _togglePostForm,
              child: Icon(_showPostForm ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
