/// Envelope returned by every El Ameed endpoint:
/// `{ success, message, data, errors }`.
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic> errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.message,
    this.data,
    this.errors = const {},
  });

  static bool _statusIsSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  /// [fromJsonT] receives the raw `data` value (a Map for object endpoints,
  /// a List for the paginated list endpoints); pass `null` for data-less calls.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode,
    T Function(Object? data)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] is bool ? json['success'] as bool : _statusIsSuccess(statusCode),
      statusCode: statusCode,
      message: json['message'] is String ? json['message'] as String : null,
      data: fromJsonT != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] is Map<String, dynamic> ? json['errors'] as Map<String, dynamic> : const {},
    );
  }
}
