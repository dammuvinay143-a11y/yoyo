import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student' or 'admin'
  final String? photoUrl;
  final String? coverPhotoUrl;
  final bool isActive;
  final DateTime createdAt;

  // Student-specific fields
  final String? rollNumber;
  final String? department;
  final int? year;
  final String? bio;
  final String? headline; // Professional headline
  final List<String> skills;
  final List<String> interests;
  
  // Social accounts
  final String? linkedinUrl;
  final String? githubUrl;
  final String? twitterUrl;
  final String? portfolioUrl;
  
  // Additional profile details
  final String? phone;
  final String? location;
  final DateTime? dateOfBirth;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.coverPhotoUrl,
    this.isActive = true,
    required this.createdAt,
    this.rollNumber,
    this.department,
    this.year,
    this.bio,
    this.headline,
    this.skills = const [],
    this.interests = const [],
    this.linkedinUrl,
    this.githubUrl,
    this.twitterUrl,
    this.portfolioUrl,
    this.phone,
    this.location,
    this.dateOfBirth,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      photoUrl: data['photoUrl'],
      coverPhotoUrl: data['coverPhotoUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      rollNumber: data['rollNumber'],
      department: data['department'],
      year: data['year'],
      bio: data['bio'],
      headline: data['headline'],
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      linkedinUrl: data['linkedinUrl'],
      githubUrl: data['githubUrl'],
      twitterUrl: data['twitterUrl'],
      portfolioUrl: data['portfolioUrl'],
      phone: data['phone'],
      location: data['location'],
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate() 
          : null,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'rollNumber': rollNumber,
      'department': department,
      'year': year,
      'bio': bio,
      'headline': headline,
      'skills': skills,
      'interests': interests,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'twitterUrl': twitterUrl,
      'portfolioUrl': portfolioUrl,
      'phone': phone,
      'location': location,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? photoUrl,
    String? coverPhotoUrl,
    bool? isActive,
    DateTime? createdAt,
    String? rollNumber,
    String? department,
    int? year,
    String? bio,
    String? headline,
    List<String>? skills,
    List<String>? interests,
    String? linkedinUrl,
    String? githubUrl,
    String? twitterUrl,
    String? portfolioUrl,
    String? phone,
    String? location,
    DateTime? dateOfBirth,
    int? followersCount,
    int? followingCount,
    int? postsCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      headline: headline ?? this.headline,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        role,
        isActive,
        followersCount,
        followingCount,
        postsCount,
      ];
}
