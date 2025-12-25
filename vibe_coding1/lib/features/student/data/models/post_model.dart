import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PostType { text, image, video, poll, achievement, event }

class PostModel extends Equatable {
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String? authorHeadline;
  final String content;
  final PostType type;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> likes;
  final List<String> shares;
  final List<CommentModel> comments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFlagged;
  final List<String> tags;
  final String? location;
  final int viewsCount;
  
  // For poll posts
  final Map<String, dynamic>? pollData;
  
  // For achievement posts
  final String? achievementType;
  final String? achievementBadge;

  const PostModel({
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    this.authorHeadline,
    required this.content,
    this.type = PostType.text,
    this.imageUrls = const [],
    this.videoUrl,
    this.likes = const [],
    this.shares = const [],
    this.comments = const [],
    required this.createdAt,
    this.updatedAt,
    this.isFlagged = false,
    this.tags = const [],
    this.location,
    this.viewsCount = 0,
    this.pollData,
    this.achievementType,
    this.achievementBadge,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      comments: (data['comments'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromMap(c))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isFlagged: data['isFlagged'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isFlagged': isFlagged,
    };
  }

  PostModel copyWith({
    List<String>? likes,
    List<CommentModel>? comments,
    bool? isFlagged,
  }) {
    return PostModel(
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      content: content,
      imageUrls: imageUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

  @override
  List<Object?> get props =>
      [postId, authorId, content, likes, comments, createdAt];
}

class CommentModel extends Equatable {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime timestamp;

  const CommentModel({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  @override
  List<Object?> get props => [userId, text, timestamp];
}
