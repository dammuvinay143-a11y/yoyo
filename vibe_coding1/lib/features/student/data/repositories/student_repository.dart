import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/student_profile_model.dart';
import '../../../auth/data/models/user_model.dart';

class StudentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  StudentRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Get student profile
  Future<StudentProfileModel?> getStudentProfile(String uid) async {
    try {
      final doc =
          await _firestore.collection('student_profiles').doc(uid).get();
      if (doc.exists) {
        return StudentProfileModel.fromFirestore(doc);
      }
      // Create default profile if doesn't exist
      final defaultProfile = StudentProfileModel(uid: uid);
      await _firestore
          .collection('student_profiles')
          .doc(uid)
          .set(defaultProfile.toFirestore(), SetOptions(merge: true));
      return defaultProfile;
    } catch (e) {
      // Return default profile even if there's an error
      return StudentProfileModel(uid: uid);
    }
  }

  // Update student profile
  Future<void> updateStudentProfile(StudentProfileModel profile) async {
    try {
      // Update student_profiles collection (use set with merge to create if not exists)
      await _firestore
          .collection('student_profiles')
          .doc(profile.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));

      // Also sync social accounts and key info to users collection for admin visibility
      final userUpdateData = <String, dynamic>{
        'linkedinUrl': profile.linkedinUrl,
        'githubUrl': profile.githubUrl,
        'portfolioUrl': profile.portfolioUrl,
        'phone': profile.phone,
        'bio': profile.bio,
        'skills': profile.skills,
      };

      // Remove null values to avoid overwriting with null
      userUpdateData.removeWhere((key, value) => value == null);

      await _firestore
          .collection('users')
          .doc(profile.uid)
          .update(userUpdateData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update user basic info
  Future<void> updateUserInfo(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user info: $e');
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_photos').child('$uid.jpg');
      
      // For web, we need to use putData with bytes
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(imageFile);
      }
      
      final photoUrl = await ref.getDownloadURL();
      
      // Update the user's photoUrl in Firestore
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'photoUrl': photoUrl});
      
      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Get all students
  Stream<List<UserModel>> getAllStudents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Search students by department
  Stream<List<UserModel>> getStudentsByDepartment(String department) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('department', isEqualTo: department)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
}
