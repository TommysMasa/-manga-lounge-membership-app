import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_state.freezed.dart';

/// Represents the user management state in the presentation layer
///
/// This state is used by UserStateNotifier to manage user-related UI state
@freezed
class UserState with _$UserState {
  /// Initial state when no user operation has been performed
  const factory UserState.initial() = _Initial;

  /// User data loaded successfully
  const factory UserState.loaded(User user) = _Loaded;

  /// Loading user data or performing operation
  const factory UserState.loading() = _Loading;

  /// Error occurred during user operation
  const factory UserState.error(String message) = _Error;

  /// No user data available (user not authenticated or profile not found)
  const factory UserState.noUser() = _NoUser;
}
