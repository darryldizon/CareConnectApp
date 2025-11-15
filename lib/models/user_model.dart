class UserModel {
  String email;
  String password;
  String role; // Volunteer, Donor, Recipient
  bool isApproved;

  UserModel({
    required this.email,
    required this.password,
    required this.role,
    this.isApproved = false,
  });
}
