import 'package:dartz/dartz.dart';

import 'failures.dart';

/// Type alias for `Either<Failure, T>`
///
/// Provides a cleaner API for functional error handling.
/// Use `Result<T>` instead of `Either<Failure, T>` for better readability.
typedef Result<T> = Either<Failure, T>;

/// Type alias for async Result
typedef AsyncResult<T> = Future<Result<T>>;

/// Type alias for stream Result
typedef StreamResult<T> = Stream<Result<T>>;

/// Convenience constructors for Result
class Results {
  Results._();

  /// Creates a successful Result
  static Result<T> success<T>(T value) => Right(value);

  /// Creates a failed Result
  static Result<T> failure<T>(Failure failure) => Left(failure);
}

/// Extension methods for `Result<T>`
extension ResultExtension<T> on Result<T> {
  /// Returns true if this is a success (Right)
  bool get isSuccess => isRight();

  /// Returns true if this is a failure (Left)
  bool get isFailure => isLeft();

  /// Returns the success value or null
  T? get valueOrNull => fold((_) => null, (value) => value);

  /// Returns the failure or null
  Failure? get failureOrNull => fold((failure) => failure, (_) => null);

  /// Returns the success value or the result of [orElse]
  T getOrElse(T Function() orElse) => fold((_) => orElse(), (value) => value);

  /// Returns the success value or throws the failure
  T getOrThrow() => fold(
        (failure) => throw failure,
        (value) => value,
      );

  /// Maps the success value to a new type
  Result<R> mapSuccess<R>(R Function(T value) mapper) => fold(
        (failure) => Left(failure),
        (value) => Right(mapper(value)),
      );

  /// Maps the failure to a new failure
  Result<T> mapFailure(Failure Function(Failure failure) mapper) => fold(
        (failure) => Left(mapper(failure)),
        (value) => Right(value),
      );

  /// Executes [onSuccess] if success, [onFailure] if failure
  void when({
    required void Function(T value) onSuccess,
    required void Function(Failure failure) onFailure,
  }) {
    fold(onFailure, onSuccess);
  }

  /// Executes [onSuccess] only if success
  void whenSuccess(void Function(T value) onSuccess) {
    fold((_) {}, onSuccess);
  }

  /// Executes [onFailure] only if failure
  void whenFailure(void Function(Failure failure) onFailure) {
    fold(onFailure, (_) {});
  }
}

/// Extension methods for `AsyncResult<T>`
extension AsyncResultExtension<T> on AsyncResult<T> {
  /// Returns the success value or null
  Future<T?> get valueOrNull async => (await this).valueOrNull;

  /// Returns the failure or null
  Future<Failure?> get failureOrNull async => (await this).failureOrNull;

  /// Returns the success value or the result of [orElse]
  Future<T> getOrElse(T Function() orElse) async =>
      (await this).getOrElse(orElse);

  /// Returns the success value or throws the failure
  Future<T> getOrThrow() async => (await this).getOrThrow();

  /// Maps the success value to a new type
  AsyncResult<R> mapSuccess<R>(R Function(T value) mapper) async =>
      (await this).mapSuccess(mapper);

  /// Executes [onSuccess] if success, [onFailure] if failure
  Future<void> when({
    required void Function(T value) onSuccess,
    required void Function(Failure failure) onFailure,
  }) async {
    (await this).when(onSuccess: onSuccess, onFailure: onFailure);
  }
}
