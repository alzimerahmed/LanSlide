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
/// Partial-transfer resume is not feasible in protocol v2 — see the
/// "Transfer resume feasibility" section in docs/research.md.
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
