/// Classifies whether a URI is a Firebase auth action link (not an app route).
///
/// Email sign-in links arrive as deep links with paths like `/firebaseauth/link`
/// or `/__/auth/callback`. These are action links (perform auth), not page routes,
/// so they must be intercepted before GoRouter tries to match them as routes.
bool isAuthActionLink(Uri uri) {
  // Firebase auth wrapper path (email sign-in deep links)
  if (uri.path == '/firebaseauth/link') return true;

  // Firebase-hosted auth handler path
  if (uri.path.startsWith('/__/auth')) return true;

  // Detect by query parameters that only appear on auth action links
  if (uri.queryParameters.containsKey('deep_link_id')) return true;
  if (uri.queryParameters.containsKey('oobCode')) return true;
  if (uri.queryParameters['mode'] == 'signIn') return true;

  return false;
}
