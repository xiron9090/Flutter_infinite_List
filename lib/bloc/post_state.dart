import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/model/post.dart';

abstract class PostState extends Equatable {
  const PostState();
  @override
  List<Object> get props => [];
}

class PostUnitialized extends PostState {}

class PostError extends PostState {}

class PostLoaded extends PostState {
  final List<Post> post;
  final bool hasReachedMax;
  const PostLoaded({this.post, this.hasReachedMax});
  PostLoaded copyWith({List<Post> post, bool hasReachedMax}) {
    return PostLoaded(post: this.post, hasReachedMax: this.hasReachedMax);
  }

  @override
  List<Object> get props => [post, hasReachedMax];
  @override
  String toString() {
    return 'PostLoaded {post: ${post.length}, hasRemachedMax:$hasReachedMax}';
  }
}
