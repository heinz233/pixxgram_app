// lib/models/user.dart

import 'photographer_profile.dart';

class User {
  final int     id;
  final String  name;
  final String  email;
  final String? phone;         // Laravel field: phoneNumber
  final int     roleId;
  final String? userImage;
  final bool    isActive;
  final String? status;        // pending | active | suspended | banned
  final String? gender;
  final String? dob;
  final String? gymLocation;
  final PhotographerProfile? photographerProfile;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.roleId,
    this.userImage,
    required this.isActive,
    this.status,
    this.gender,
    this.dob,
    this.gymLocation,
    this.photographerProfile,
  });

  bool get isAdmin        => roleId == 1;
  bool get isPhotographer => roleId == 2;
  bool get isClient       => roleId == 3;

  // Build full image URL from storage path
  String? get imageUrl {
    if (userImage == null || userImage!.isEmpty) return null;
    if (userImage!.startsWith('http')) return userImage;
    return 'http://192.168.100.8:8000/storage/$userImage';
  }

  factory User.fromJson(Map<String, dynamic> j) => User(
        id:        j['id'] is String ? int.parse(j['id']) : (j['id'] ?? 0),
        name:      j['name'] ?? '',
        email:     j['email'] ?? '',
        phone:     j['phoneNumber'],           // Laravel uses phoneNumber
        roleId:    j['role_id'] ?? 3,
        userImage: j['user_image'],
        isActive:  j['is_active'] == true || j['is_active'] == 1,
        status:    j['status'],
        gender:    j['gender'],
        dob:       j['dob'],
        gymLocation: j['gymLocation'],
        photographerProfile: j['photographer_profile'] != null
            ? PhotographerProfile.fromJson(j['photographer_profile'])
            : null,
      );
}