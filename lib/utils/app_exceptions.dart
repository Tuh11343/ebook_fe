// app_exceptions.dart
class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException(this.message, [this.prefix, this.statusCode]);

  @override
  String toString() {
    return "$prefix: $message (Code: $statusCode)";
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message, [int? statusCode])
      : super(message, "Error During Communication", statusCode);
}

class BadRequestException extends AppException {
  BadRequestException(String message, [int? statusCode])
      : super(message, "Invalid Request", statusCode);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message, [int? statusCode])
      : super(message, "Unauthorized", statusCode);
}

class NotFoundException extends AppException {
  NotFoundException(String message, [int? statusCode])
      : super(message, "Not Found", statusCode);
}

class ApiException extends AppException {
  ApiException(String message, [int? statusCode])
      : super(message, "API Error", statusCode);
}

// Thêm các exception khác nếu cần (ví dụ: ServerException, NoInternetException)