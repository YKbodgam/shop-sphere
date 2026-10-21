import 'package:equatable/equatable.dart';

abstract interface class RepositoryFailure implements Exception {
  String get userMessage;
}

abstract interface class LoadableState {
  bool get isLoading;
  String? get errorMessage;
}

class PageRequest extends Equatable {
  const PageRequest({this.skip = 0, this.limit = 20});
  final int skip;
  final int limit;
  @override
  List<Object?> get props => [skip, limit];
}
