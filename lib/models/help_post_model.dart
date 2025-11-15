class HelpPost {
  String type; // Request / Offer
  String category; // Food / Shelter / Medicine / Supplies / Volunteer
  String description;
  String location;
  String user;
  bool isVerified;
  bool isPinned;
  int likes;
  List<String> comments;
  String? imageUrl;
  bool reported;

  HelpPost({
    required this.type,
    required this.category,
    required this.description,
    required this.location,
    required this.user,
    this.isVerified = true,
    this.isPinned = false,
    this.likes = 0,
    List<String>? comments,
    this.imageUrl,
    this.reported = false,
  }) : comments = comments ?? [];
}
