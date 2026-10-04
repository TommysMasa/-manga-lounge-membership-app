import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../subscription/presentation/widgets/premium_widgets.dart';

final memberRequestDetailProvider = StreamProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, id) {
      return ref
          .watch(firestoreProvider)
          .collection('memberRequests')
          .doc(id)
          .snapshots()
          .map((snap) => snap.data());
    });

/// Reads the saved result rather than trusting text supplied in a push payload.
class MemberRequestDetailScreen extends ConsumerWidget {
  const MemberRequestDetailScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(memberRequestDetailProvider(requestId));
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(middle: Text('Your Request')),
      child: SafeArea(
        child: request.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Couldn’t load this request.',
                    textAlign: TextAlign.center,
                  ),
                  CupertinoButton(
                    onPressed: () =>
                        ref.invalidate(memberRequestDetailProvider(requestId)),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            if (data == null) {
              return const Center(
                child: Text('This request is no longer available.'),
              );
            }
            final manga = data['type'] == 'manga';
            final status = data['status'] as String? ?? 'pending';
            final arrived = status == 'arrived' || status == 'completed';
            final ordered = status == 'ordered';
            final cancelled = status == 'cancelled';
            final reply = data['staffReply'] as String? ?? '';
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(
                  arrived
                      ? CupertinoIcons.check_mark_circled
                      : cancelled
                          ? CupertinoIcons.xmark_circle
                          : CupertinoIcons.clock,
                  size: 40,
                  color: cancelled ? CupertinoColors.systemRed : kPremiumBlue,
                ),
                const SizedBox(height: 20),
                Text(
                  cancelled
                      ? (manga ? 'We couldn’t add this manga' : 'We couldn’t fulfill your suggestion')
                      : arrived
                          ? (manga ? 'Your manga has arrived!' : 'Your suggestion has been addressed')
                          : ordered
                              ? (manga ? 'Your manga has been ordered' : 'Your suggestion is in progress')
                              : 'Request received',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (manga)
                  Text(
                    data['title'] as String? ?? '',
                    style: const TextStyle(fontSize: 20),
                  ),
                if ((data['volumes'] as String? ?? '').isNotEmpty)
                  Text('Volumes: ${data['volumes']}'),
                if ((data['details'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(data['details'] as String),
                ],
                if (ordered) ...[
                  const SizedBox(height: 20),
                  Text(manga
                      ? 'We’ll notify you again when it arrives.'
                      : 'We’ll notify you when it’s complete.'),
                ],
                if (arrived && manga) ...[
                  const SizedBox(height: 20),
                  const Text('Now available at Manga Lounge.'),
                ],
                if (reply.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'From Manga Lounge',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(reply),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
