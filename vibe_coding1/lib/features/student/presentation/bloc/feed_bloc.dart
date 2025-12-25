import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/feed_repository.dart';
import 'dart:io';

// Events
abstract class FeedEvent extends Equatable {
  const FeedEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeed extends FeedEvent {}

class CreatePost extends FeedEvent {
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final List<File>? images;

  const CreatePost({
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.images,
  });

  @override
  List<Object?> get props => [authorId, authorName, content, images];
}

class ToggleLike extends FeedEvent {
  final String postId;
  final String userId;

  const ToggleLike(this.postId, this.userId);

  @override
  List<Object?> get props => [postId, userId];
}

class AddComment extends FeedEvent {
  final String postId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;

  const AddComment({
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
  });

  @override
  List<Object?> get props => [postId, userId, text];
}

class ReportPost extends FeedEvent {
  final String postId;
  const ReportPost(this.postId);
  @override
  List<Object?> get props => [postId];
}

class DeletePost extends FeedEvent {
  final String postId;
  const DeletePost(this.postId);
  @override
  List<Object?> get props => [postId];
}

// States
abstract class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<PostModel> posts;
  const FeedLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class PostCreated extends FeedState {}

class PostActionSuccess extends FeedState {
  final String message;
  const PostActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class FeedError extends FeedState {
  final String message;
  const FeedError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _repository;

  FeedBloc({required FeedRepository repository})
      : _repository = repository,
        super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<CreatePost>(_onCreatePost);
    on<ToggleLike>(_onToggleLike);
    on<AddComment>(_onAddComment);
    on<ReportPost>(_onReportPost);
    on<DeletePost>(_onDeletePost);
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      await emit.forEach(
        _repository.getPosts(),
        onData: (List<PostModel> posts) => FeedLoaded(posts),
        onError: (error, stackTrace) => FeedError(error.toString()),
      );
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      await _repository.createPost(
        authorId: event.authorId,
        authorName: event.authorName,
        authorPhotoUrl: event.authorPhotoUrl,
        content: event.content,
        images: event.images,
      );
      emit(PostCreated());
      add(LoadFeed());
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<FeedState> emit) async {
    try {
      await _repository.toggleLike(event.postId, event.userId);
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onAddComment(AddComment event, Emitter<FeedState> emit) async {
    try {
      await _repository.addComment(
        postId: event.postId,
        userId: event.userId,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
        text: event.text,
      );
      emit(const PostActionSuccess('Comment added'));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onReportPost(ReportPost event, Emitter<FeedState> emit) async {
    try {
      await _repository.reportPost(event.postId);
      emit(const PostActionSuccess('Post reported'));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<FeedState> emit) async {
    try {
      await _repository.deletePost(event.postId);
      emit(const PostActionSuccess('Post deleted'));
      add(LoadFeed());
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
