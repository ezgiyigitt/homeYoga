/// Sealed Result type for use cases and repositories.
///
/// Inspired by Kotlin's Result and Swift's Result type.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  String? get errorOrNull =>
      isFailure ? (this as Failure<T>).message : null;

  /// Executes [onSuccess] if success, [onFailure] if failure.
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String message) onFailure,
  }) {
    return switch (this) {
      Success<T> s => onSuccess(s.data),
      Failure<T> f => onFailure(f.message),
    };
  }

  /// Maps the success value to another type.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T> s => Success(transform(s.data)),
      Failure<T> f => Failure(f.message),
    };
  }

  /// Wraps a future in a [Result], catching exceptions as [Failure].
  static Future<Result<T>> guard<T>(Future<T> Function() fn) async {
    try {
      return Success(await fn());
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

/// Successful result carrying [data].
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// Failed result carrying an error [message].
final class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);

  @override
  String toString() => 'Failure($message)';
}
