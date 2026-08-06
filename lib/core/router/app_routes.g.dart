// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $phoneInputRoute,
  $oTPRoute,
  $registerRoute,
  $homeRoute,
  $changePhoneNumberRoute,
  $changeEmailAddressRoute,
  $surveyRoute,
  $eventAnnouncementRoute,
  $waitlistJoinRoute,
];

RouteBase get $splashRoute =>
    GoRouteData.$route(path: '/', factory: $SplashRoute._fromState);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $phoneInputRoute => GoRouteData.$route(
  path: '/phone-input',
  factory: $PhoneInputRoute._fromState,
);

mixin $PhoneInputRoute on GoRouteData {
  static PhoneInputRoute _fromState(GoRouterState state) =>
      const PhoneInputRoute();

  @override
  String get location => GoRouteData.$location('/phone-input');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $oTPRoute => GoRouteData.$route(
  path: '/otp-verification',
  factory: $OTPRoute._fromState,
);

mixin $OTPRoute on GoRouteData {
  static OTPRoute _fromState(GoRouterState state) => const OTPRoute();

  @override
  String get location => GoRouteData.$location('/otp-verification');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $registerRoute =>
    GoRouteData.$route(path: '/register', factory: $RegisterRoute._fromState);

mixin $RegisterRoute on GoRouteData {
  static RegisterRoute _fromState(GoRouterState state) => const RegisterRoute();

  @override
  String get location => GoRouteData.$location('/register');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute =>
    GoRouteData.$route(path: '/home', factory: $HomeRoute._fromState);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $changePhoneNumberRoute => GoRouteData.$route(
  path: '/change-phone-number',
  factory: $ChangePhoneNumberRoute._fromState,
);

mixin $ChangePhoneNumberRoute on GoRouteData {
  static ChangePhoneNumberRoute _fromState(GoRouterState state) =>
      const ChangePhoneNumberRoute();

  @override
  String get location => GoRouteData.$location('/change-phone-number');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $changeEmailAddressRoute => GoRouteData.$route(
  path: '/change-email-address',
  factory: $ChangeEmailAddressRoute._fromState,
);

mixin $ChangeEmailAddressRoute on GoRouteData {
  static ChangeEmailAddressRoute _fromState(GoRouterState state) =>
      const ChangeEmailAddressRoute();

  @override
  String get location => GoRouteData.$location('/change-email-address');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $surveyRoute =>
    GoRouteData.$route(path: '/survey', factory: $SurveyRoute._fromState);

mixin $SurveyRoute on GoRouteData {
  static SurveyRoute _fromState(GoRouterState state) =>
      SurveyRoute(form: state.uri.queryParameters['form'] ?? '');

  SurveyRoute get _self => this as SurveyRoute;

  @override
  String get location => GoRouteData.$location(
    '/survey',
    queryParams: {if (_self.form != '') 'form': _self.form},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $eventAnnouncementRoute => GoRouteData.$route(
  path: '/event',
  factory: $EventAnnouncementRoute._fromState,
);

mixin $EventAnnouncementRoute on GoRouteData {
  static EventAnnouncementRoute _fromState(GoRouterState state) =>
      EventAnnouncementRoute(
        imageUrl: state.uri.queryParameters['image-url'] ?? '',
        ticketUrl: state.uri.queryParameters['ticket-url'] ?? '',
        title: state.uri.queryParameters['title'] ?? '',
      );

  EventAnnouncementRoute get _self => this as EventAnnouncementRoute;

  @override
  String get location => GoRouteData.$location(
    '/event',
    queryParams: {
      if (_self.imageUrl != '') 'image-url': _self.imageUrl,
      if (_self.ticketUrl != '') 'ticket-url': _self.ticketUrl,
      if (_self.title != '') 'title': _self.title,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $waitlistJoinRoute => GoRouteData.$route(
  path: '/waitlist',
  factory: $WaitlistJoinRoute._fromState,
);

mixin $WaitlistJoinRoute on GoRouteData {
  static WaitlistJoinRoute _fromState(GoRouterState state) =>
      const WaitlistJoinRoute();

  @override
  String get location => GoRouteData.$location('/waitlist');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
