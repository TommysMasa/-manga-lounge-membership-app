import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';

enum MemberRequestType {
  manga('Manga Requests'),
  suggestion('Suggestions');

  const MemberRequestType(this.title);
  final String title;
}

class MemberRequestDraft {
  const MemberRequestDraft({
    required this.id,
    required this.type,
    required this.title,
    required this.details,
    this.volumes = '',
    this.source = 'settings',
  });
  final String id;
  final MemberRequestType type;
  final String title;
  final String details;
  final String volumes;
  final String source;

  Map<String, Object> toJson() => {
    'requestId': id,
    'type': type.name,
    'title': title.trim(),
    'details': details.trim(),
    'volumes': volumes.trim(),
    'source': source,
  };
}

/// Overridable boundary for the native form; authentication
/// is validated by the callable rather than trusting client-supplied UID.
final submitMemberRequestProvider =
    Provider<Future<void> Function(MemberRequestDraft)>((ref) {
      return (draft) async {
        await ref
            .read(functionsProvider)
            .httpsCallable('submitMemberRequest')
            .call(draft.toJson());
      };
    });

final newMemberRequestIdProvider = Provider<String Function()>((ref) {
  return () =>
      ref.read(firestoreProvider).collection('memberRequests').doc().id;
});
