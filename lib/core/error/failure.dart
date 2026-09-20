abstract class Failure {
  const Failure(this.message, {this.statusCode});

  final String message;
  final String? statusCode;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Network Connection Error',

  ]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'An unexpected error occurred',
  ]);
}
