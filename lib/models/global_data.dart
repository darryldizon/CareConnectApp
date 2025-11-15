import 'user_model.dart';

// Global users list
List<UserModel> users = [
  UserModel(email: 'admin', password: 'admin', role: 'Admin', isApproved: true),
  UserModel(email: 'v', password: '1', role: 'Volunteer', isApproved: true),
  UserModel(email: 'd', password: '1', role: 'Donor', isApproved: true),
  UserModel(email: 'r', password: '1', role: 'Recipient', isApproved: true),
];
