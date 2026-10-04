import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'events_repository.dart';

final eventTicketLinkProvider = Provider<Future<String> Function(LoungeEvent)>((
  ref,
) {
  return (event) async {
    final result = await FirebaseFunctions.instance
        .httpsCallable(
          'createEventTicketLink',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
        )
        .call<Map<String, dynamic>>({'eventId': event.id});
    final url = result.data['url'];
    final parsed = url is String ? Uri.tryParse(url) : null;
    if (parsed == null || parsed.scheme != 'https' || parsed.host.isEmpty) {
      throw const FormatException('Invalid ticket link');
    }
    return url as String;
  };
});
