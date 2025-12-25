import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/post_model.dart';

class FeedRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FeedRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Get all posts
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // Create post
  Future<void> createPost({
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    List<File>? images,
  }) async {
    try {
      List<String> imageUrls = [];

      // Upload images if any
      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final ref = _storage.ref().child('post_images').child(fileName);
          await ref.putFile(images[i]);
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      final post = PostModel(
        postId: '',
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('posts').add(post.toFirestore());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Like/Unlike post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        final post = PostModel.fromFirestore(doc);
        List<String> likes = List.from(post.likes);

        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        await _firestore
            .collection('posts')
            .doc(postId)
            .update({'likes': likes});
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Add comment
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String text,
  }) async {
    try {
      final comment = CommentModel(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        text: text,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()])
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Report post
  Future<void> reportPost(String postId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'isFlagged': true});
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
