class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class AppDatabaseException extends AppException {
  const AppDatabaseException(super.message, {super.cause});
}

class FileException extends AppException {
  const FileException(super.message, {super.cause});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.cause});
}

class PdfException extends AppException {
  const PdfException(super.message, {super.cause});
}
