import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_lounge/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:manga_lounge/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:manga_lounge/features/auth/presentation/screens/splash_screen.dart';
import 'package:manga_lounge/features/user/presentation/screens/change_email_address_screen.dart';
import 'package:manga_lounge/features/user/presentation/screens/change_phone_number_screen.dart';
import 'package:manga_lounge/features/survey/presentation/screens/survey_screen.dart';
import 'package:manga_lounge/features/user/presentation/screens/home_screen.dart';
import 'package:manga_lounge/features/user/presentation/screens/registration_screen.dart';

part 'app_routes.g.dart';

/// Root route - Splash screen
///
/// This is the initial route that users see when opening the app.
/// It checks authentication state and redirects accordingly.
@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}

/// Phone input route - First step of authentication
///
/// Users enter their phone number here to start the authentication flow.
@TypedGoRoute<PhoneInputRoute>(path: '/phone-input')
class PhoneInputRoute extends GoRouteData with $PhoneInputRoute {
  const PhoneInputRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PhoneInputScreen();
  }
}

/// OTP verification route - Second step of authentication
///
/// Users enter the OTP code sent to their phone number.
@TypedGoRoute<OTPRoute>(path: '/otp-verification')
class OTPRoute extends GoRouteData with $OTPRoute {
  const OTPRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OTPVerificationScreen();
  }
}

/// Registration route - Complete user profile
///
/// New users complete their registration by providing additional details.
@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RegistrationScreen();
  }
}

/// Home route - Main application screen
///
/// The main screen users see after successful authentication.
@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

/// Phone number change route - Change phone number for authenticated users
///
/// Authenticated users can change their phone number via SMS verification.
@TypedGoRoute<ChangePhoneNumberRoute>(path: '/change-phone-number')
class ChangePhoneNumberRoute extends GoRouteData with $ChangePhoneNumberRoute {
  const ChangePhoneNumberRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChangePhoneNumberScreen();
  }
}

/// Email address change route - Change email address for authenticated users
///
/// Authenticated users can change their email address via phone SMS verification.
@TypedGoRoute<ChangeEmailAddressRoute>(path: '/change-email-address')
class ChangeEmailAddressRoute extends GoRouteData with $ChangeEmailAddressRoute {
  const ChangeEmailAddressRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChangeEmailAddressScreen();
  }
}

/// Survey route - In-app Tally survey linked to the user's UID
///
/// Opened via universal link (QR code in the lounge):
/// `https://simpleapp-5c1c6.web.app/survey?form=<tallyFormId>`
@TypedGoRoute<SurveyRoute>(path: '/survey')
class SurveyRoute extends GoRouteData with $SurveyRoute {
  const SurveyRoute({this.form = ''});

  /// Tally form ID passed as a query parameter
  final String form;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // Key by form ID so navigating to a different survey rebuilds the
    // screen (and its WebView) instead of reusing the previous one.
    return SurveyScreen(key: ValueKey(form), formId: form);
  }
}
