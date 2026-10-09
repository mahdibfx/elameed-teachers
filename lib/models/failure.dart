import 'package:teachers_app/ui/common/app_strings.dart';

/// Left side of every `Either<Failure, T>` returned by the services.
abstract class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

class GeneralFailure extends Failure {
  GeneralFailure(super.message);
}

class NoInternetFailure extends Failure {
  NoInternetFailure() : super(AppStrings.internetFailure);
}

/// 400/422 validation failure carrying the API's per-field `errors` map.
class ValidationFailure extends Failure {
  final Map<String, dynamic> errors;
  ValidationFailure(super.message, [this.errors = const {}]);

  String? get firstError {
    if (errors.isEmpty) return null;
    final value = errors.values.first;
    if (value is List && value.isNotEmpty) return value.first.toString();
    return value?.toString();
  }
}
