import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/widget/dialogs/custom_bottom_sheet.dart';
import 'package:routerino/routerino.dart';

/// Explain-then-ask rationale for the Android "Nearby devices" / local network
/// permission (Android 13+ nearby devices, Android 17+ local network).
///
/// Shown before the OS permission dialog so the user understands why the
/// permission is needed: UDP multicast discovery and LAN transfers are blocked
/// by the OS until it is granted. Nothing leaves the local network.
///
/// Returns true when the user chose to continue to the OS dialog.
class LocalNetworkRationaleSheet extends StatelessWidget {
  const LocalNetworkRationaleSheet({super.key});

  /// Shows the rationale and returns whether the user wants to proceed.
  static Future<bool> show(BuildContext context) async {
    final result = await context.pushBottomSheet<bool, Widget>(() => const LocalNetworkRationaleSheet());
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: t.onboarding.localNetwork.title,
      description: t.onboarding.localNetwork.description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Bullet(text: t.onboarding.localNetwork.bulletDiscovery),
          _Bullet(text: t.onboarding.localNetwork.bulletTransfer),
          _Bullet(text: t.onboarding.localNetwork.bulletPrivacy),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => context.pop(false),
                child: Text(t.onboarding.localNetwork.notNow),
              ),
              ElevatedButton.icon(
                onPressed: () => context.pop(true),
                icon: const Icon(Icons.wifi),
                label: Text(t.onboarding.localNetwork.continueLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
