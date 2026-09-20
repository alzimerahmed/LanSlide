import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/trusted_device.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/trusted_devices_provider.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// Manage the trusted devices (fingerprint allowlist).
class TrustedDevicesPage extends StatelessWidget {
  const TrustedDevicesPage({super.key});

  Future<void> _addFromKnownPeers(BuildContext context) async {
    final trusted = context.read(trustedDevicesProvider);
    final favorites = context.read(favoritesProvider).where((f) => TrustedDevice.find(trusted, f.fingerprint) == null);
    final nearby = context.read(nearbyDevicesProvider).devices.values.where((d) => TrustedDevice.find(trusted, d.fingerprint) == null);

    final candidates = <(String fingerprint, String alias)>[
      for (final f in favorites) (f.fingerprint, f.alias),
      for (final d in nearby) (d.fingerprint, d.alias),
    ];

    if (!context.mounted) {
      return;
    }

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.trustedDevicesPage.noKnownPeers)));
      return;
    }

    final selected = await showDialog<(String, String)>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(t.trustedDevicesPage.addFromPeers),
        children: [
          for (final (fingerprint, alias) in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop((fingerprint, alias)),
              child: Text(alias, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );

    if (selected != null && context.mounted) {
      await context
          .redux(trustedDevicesProvider)
          .dispatchAsync(
            AddTrustedDeviceAction(
              TrustedDevice(
                fingerprint: selected.$1,
                alias: selected.$2,
                alwaysAccept: false,
                addedAt: DateTime.now().toUtc(),
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trusted = context.watch(trustedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.trustedDevicesPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(t.trustedDevicesPage.info, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton.icon(
              onPressed: () async {
                await _addFromKnownPeers(context);
              },
              icon: const Icon(Icons.add),
              label: Text(t.trustedDevicesPage.addFromKnownPeers),
            ),
          ),
          const SizedBox(height: 10),
          if (trusted.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Center(child: Text(t.trustedDevicesPage.empty, style: Theme.of(context).textTheme.headlineMedium)),
            )
          else
            ...trusted.map((device) {
              return ListTile(
                title: Text(device.alias),
                subtitle: Text(device.fingerprint, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.trustedDevicesPage.alwaysAccept),
                    Switch(
                      value: device.alwaysAccept,
                      onChanged: (value) async {
                        await context
                            .redux(trustedDevicesProvider)
                            .dispatchAsync(
                              UpdateTrustedDeviceAction(device.copyWith(alwaysAccept: value)),
                            );
                      },
                    ),
                    IconButton(
                      onPressed: () async {
                        await context.redux(trustedDevicesProvider).dispatchAsync(RemoveTrustedDeviceAction(fingerprint: device.fingerprint));
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
