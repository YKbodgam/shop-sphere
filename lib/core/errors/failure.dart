sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Check your internet connection and try again.',
  ]);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request took too long. Please try again.',
  ]);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please sign in again.',
  ]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find that product.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our server.']);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'We could not save your changes.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

String userFacingFailure(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  return error is Failure ? error.message : fallback;
}
