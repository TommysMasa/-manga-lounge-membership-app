import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation.freezed.dart';
part 'navigation.g.dart';

@Riverpod(keepAlive: true)
NavigationState navigation(Ref ref) => throw UnimplementedError();

@freezed
abstract class NavigationState with _$NavigationState {
  factory NavigationState({required GlobalKey<NavigatorState> rootNavKey}) =
      _NavigationState;
  NavigationState._();

  BuildContext get rootContext => rootNavKey.currentState!.descendantContext;
}

extension NavigatorStateExtension on NavigatorState {
  BuildContext get descendantContext => overlay!.context;
}
