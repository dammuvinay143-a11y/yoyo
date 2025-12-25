import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/post_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/feed_bloc.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.uid : '';
    final isLiked = post.likes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.authorPhotoUrl != null
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  child: post.authorPhotoUrl == null
                      ? Text(post.authorName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.authorId == currentUserId)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                        onTap: () {
                          context.read<FeedBloc>().add(DeletePost(post.postId));
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),

            // Images
            if (post.imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(post.imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                // Like button
                TextButton.icon(
                  onPressed: () {
                    context
                        .read<FeedBloc>()
                        .add(ToggleLike(post.postId, currentUserId));
                  },
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  label: Text('${post.likes.length}'),
                ),
                const SizedBox(width: 8),

                // Comment button
                TextButton.icon(
                  onPressed: () {
                    _showCommentSheet(context, post, currentUserId);
                  },
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('${post.comments.length}'),
                ),
                const Spacer(),

                // Report button
                if (post.authorId != currentUserId)
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, size: 20),
                    onPressed: () {
                      context.read<FeedBloc>().add(ReportPost(post.postId));
                    },
                  ),
              ],
            ),

            // Comments preview
            if (post.comments.isNotEmpty) ...[
              const Divider(),
              Column(
                children: post.comments.take(2).map((comment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: comment.userPhotoUrl != null
                              ? NetworkImage(comment.userPhotoUrl!)
                              : null,
                          child: comment.userPhotoUrl == null
                              ? Text(comment.userName[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                comment.text,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (post.comments.length > 2)
                TextButton(
                  onPressed: () {
                    _showCommentSheet(context, post, currentUserId);
                  },
                  child: Text('View all ${post.comments.length} comments'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCommentSheet(BuildContext context, PostModel post, String userId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: post.comments.length,
                  itemBuilder: (context, index) {
                    final comment = post.comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: comment.userPhotoUrl != null
                            ? NetworkImage(comment.userPhotoUrl!)
                            : null,
                        child: comment.userPhotoUrl == null
                            ? Text(comment.userName[0].toUpperCase())
                            : null,
                      ),
                      title: Text(comment.userName),
                      subtitle: Text(comment.text),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (commentController.text.trim().isNotEmpty) {
                        context.read<FeedBloc>().add(
                              AddComment(
                                postId: post.postId,
                                userId: userId,
                                userName: authState.user.name,
                                userPhotoUrl: authState.user.photoUrl,
                                text: commentController.text.trim(),
                              ),
                            );
                        commentController.clear();
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
