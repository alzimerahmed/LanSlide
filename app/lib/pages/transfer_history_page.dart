import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/model/persistence/transfer_history_entry.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/provider/transfer_history_provider.dart';
import 'package:localsend_app/widget/dialogs/history_clear_dialog.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:localsend_isolates/constants.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// Unified transfer history (sent + received transfers).
class TransferHistoryPage extends StatelessWidget {
  const TransferHistoryPage({super.key});

  Future<void> _resend(BuildContext context, TransferHistoryEntry entry) async {
    if (entry.peerIp == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.transferHistoryPage.resendUnavailable)));
      return;
    }

    final files = <CrossFile>[];
    final skipped = <String>[];
    for (final file in entry.files) {
      final path = file.path;
      if (path == null || !await File(path).exists()) {
        skipped.add(file.fileName);
        continue;
      }
      files.add(
        CrossFile(
          name: file.fileName,
          fileType: file.fileType,
          size: file.fileSize,
          thumbnail: null,
          asset: null,
          path: file.path,
          bytes: null,
          lastModified: null,
          lastAccessed: null,
        ),
      );
    }

    if (files.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.transferHistoryPage.resendUnavailable)));
      return;
    }

    if (skipped.isNotEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.transferHistoryPage.resendSkipped(files: skipped.join(', ')))),
      );
    }

    if (entry.peerFingerprint == null) {
      // Without a fingerprint the session cannot be pinned to the peer's
      // certificate; resending would fail opaque cert verification.
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.transferHistoryPage.resendUnavailable)));
      return;
    }

    if (!context.mounted) {
      return;
    }

    // Prefer a fresh discovery match (current ip/port/https/version) over the
    // possibly-stale address stored at record time.
    final nearby = context.read(nearbyDevicesProvider).devices.values;
    final discovered = nearby.where((d) => d.fingerprint == entry.peerFingerprint).firstOrNull;

    final target =
        discovered ??
        Device(
          signalingId: null,
          ip: entry.peerIp,
          version: protocolVersion,
          port: entry.peerPort,
          https: entry.peerHttps,
          fingerprint: entry.peerFingerprint!,
          alias: entry.peerAlias,
          deviceModel: null,
          // The fields below are not used by the v2 HTTP send path; they only
          // satisfy the Device constructor.
          deviceType: DeviceType.desktop,
          download: true,
          channels: const [],
        );

    // Reuses the regular send flow (prepare request -> decision -> upload).
    unawaited(
      context
          .notifier(sendProvider)
          .startSession(
            target: target,
            files: files,
            background: false,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch(transferHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.transferHistoryPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: entries.isEmpty
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => const HistoryClearDialog(),
                          );
                          if (confirmed == true) {
                            // ignore: use_build_context_synchronously
                            await context.redux(transferHistoryProvider).dispatchAsync(RemoveAllTransferHistoryEntriesAction());
                          }
                        },
                  icon: const Icon(Icons.delete),
                  label: Text(t.transferHistoryPage.deleteHistory),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Center(child: Text(t.transferHistoryPage.empty, style: Theme.of(context).textTheme.headlineMedium)),
            )
          else
            ...entries.map((entry) {
              return ListTile(
                leading: Icon(
                  switch (entry.direction) {
                    TransferDirection.sent => Icons.upload,
                    TransferDirection.received => Icons.download,
                  },
                ),
                title: Text(
                  entry.files.map((f) => f.fileName).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${entry.timestampString} · ${entry.peerAlias} · ${entry.statusLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: entry.direction == TransferDirection.sent
                    ? IconButton(
                        tooltip: t.transferHistoryPage.resend,
                        icon: const Icon(Icons.replay),
                        onPressed: () async {
                          await _resend(context, entry);
                        },
                      )
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

extension on TransferHistoryEntry {
  String get statusLabel {
    return switch (status) {
      TransferStatus.completed => t.transferHistoryPage.status.completed,
      TransferStatus.failed => t.transferHistoryPage.status.failed,
      TransferStatus.canceled => t.transferHistoryPage.status.canceled,
      TransferStatus.declined => t.transferHistoryPage.status.declined,
    };
  }
}
