import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/model/post.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClien;
  PostBloc({@required this.httpClien});
 
  
  @override
  Stream<Transition<PostEvent, PostState>> transformEvents(
    Stream<PostEvent> events,
    TransitionFunction<PostEvent, PostState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }
   @override
  PostState get initialState => PostUnitialized();

  @override
  Stream<PostState> mapEventToState(
    PostEvent event,
  ) async* {
    final currentState = state;
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostUnitialized) {
          final posts = await _fetchPost(0, 20);
          yield PostLoaded(post: posts, hasReachedMax: false);
          return;
        }
        if (currentState is PostLoaded) {
          final post = await _fetchPost(currentState.post.length, 20);
          yield post.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostLoaded(
                  post: currentState.post + post, hasReachedMax: false);
        }
      } catch (_) {
        yield PostError();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostLoaded && state.hasReachedMax;
  Future<List<Post>> _fetchPost(int startIndex, int limit) async {
    final response = await httpClien.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
            id: rawPost['id'], title: rawPost['title'], body: rawPost['body']);
      }).toList();
    }else
    throw Exception('error fetching post');
  }
}
