import 'package:dart_mappable/dart_mappable.dart';
import 'package:intl/intl.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_isolates/model/file_type.dart';

part 'transfer_history_entry.mapper.dart';

@MappableEnum()
enum TransferDirection { sent, received }

@MappableEnum()
enum TransferStatus { completed, failed, canceled, declined }

@MappableClass()
class TransferHistoryFile with TransferHistoryFileMappable {
  final String fileName;
  final int fileSize;
  final FileType fileType;

  /// Local path of the file after a completed transfer (null otherwise).
  final String? path;

  const TransferHistoryFile({
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.path,
  });

  static const fromJson = TransferHistoryFileMapper.fromJson;
}

/// One entry per transfer session (not per file) in the unified transfer
/// history, covering both directions.
///
/// RESUME FEASIBILITY NOTE (task 3.15, investigate-only):
/// Protocol v2 has no resume support. A partial-transfer resume would require:
/// 1. packages/core: the `/api/localsend/v2/upload` handler would need to accept
///    a `Range`/offset per file token and append to a partially written file
///    instead of truncating; the prepare-upload response would need to report
///    already-received byte ranges (e.g. a per-file `receivedBytes` field).
///    This changes the v2 wire contract, which is locked by
///    packages/core/tests/protocol_compat.rs — it would have to be a v3
///    extension (or an opt-in header both sides negotiate).
/// 2. The Rust server isolate writes files streaming; it would need to keep
///    partial files and their byte offsets across sessions (persisted session
///    state), plus checksum verification of the partial prefix.
/// 3. The sender (send_provider.dart) would need to slice file reads from the
///    resume offset and the UI would need per-file "resume/restart" affordances.
/// Verdict: doable but it slips past v1 — it is a protocol-level change, not a
/// Dart-side one, and would break wire compat with stock LocalSend peers if
/// done inside v2.
@MappableClass()
class TransferHistoryEntry with TransferHistoryEntryMappable {
  final String id;
  final TransferDirection direction;
  final TransferStatus status;

  final String peerAlias;
  final String? peerFingerprint;
  final String? peerIp;
  final int peerPort;
  final bool peerHttps;

  final List<TransferHistoryFile> files;
  final bool isMessage;
  final DateTime timestamp;

  const TransferHistoryEntry({
    required this.id,
    required this.direction,
    required this.status,
    required this.peerAlias,
    required this.peerFingerprint,
    required this.peerIp,
    required this.peerPort,
    required this.peerHttps,
    required this.files,
    required this.isMessage,
    required this.timestamp,
  });

  /// Format string using the intl package (same pattern as the receive history entry).
  String get timestampString {
    final localTimestamp = timestamp.toLocal();
    final languageTag = LocaleSettings.currentLocale.languageTag;
    return '${DateFormat.yMd(languageTag).format(localTimestamp)} ${DateFormat.jm(languageTag).format(localTimestamp)}';
  }

  static const fromJson = TransferHistoryEntryMapper.fromJson;
}
