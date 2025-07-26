abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ImageUploadFailure extends Failure {
  const ImageUploadFailure(super.message);
}

class ImageUnsupportedFailure extends Failure {
  const ImageUnsupportedFailure(super.message);
}
