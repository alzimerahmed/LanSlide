import 'package:localsend_app/model/persistence/transfer_history_entry.dart';
import 'package:localsend_app/model/persistence/trusted_device.dart';
import 'package:localsend_isolates/model/file_type.dart';
import 'package:test/test.dart';

void main() {
  group('TrustedDevice allowlist matching', () {
    final t0 = DateTime.utc(2024);
    final devices = [
      TrustedDevice(fingerprint: 'fp-a', alias: 'Alice', alwaysAccept: true, addedAt: t0),
      TrustedDevice(fingerprint: 'fp-b', alias: 'Bob', alwaysAccept: false, addedAt: t0),
    ];

    test('find returns the matching device', () {
      expect(TrustedDevice.find(devices, 'fp-a')?.alias, 'Alice');
      expect(TrustedDevice.find(devices, 'fp-b')?.alias, 'Bob');
      expect(TrustedDevice.find(devices, 'unknown'), isNull);
    });

    test('shouldAutoAccept only for always-accept entries', () {
      expect(TrustedDevice.shouldAutoAccept(devices, 'fp-a'), isTrue);
      expect(TrustedDevice.shouldAutoAccept(devices, 'fp-b'), isFalse);
      expect(TrustedDevice.shouldAutoAccept(devices, 'unknown'), isFalse);
      expect(TrustedDevice.shouldAutoAccept(const [], 'fp-a'), isFalse);
    });
  });

  group('TransferHistoryEntry serialization', () {
    test('json roundtrip keeps all fields', () {
      final entry = TransferHistoryEntry(
        id: 'session-1',
        direction: TransferDirection.sent,
        status: TransferStatus.completed,
        peerAlias: 'Phone',
        peerFingerprint: 'fp',
        peerIp: '192.168.1.2',
        peerPort: 53317,
        peerHttps: true,
        files: const [
          TransferHistoryFile(fileName: 'a.png', fileSize: 123, fileType: FileType.image, path: '/tmp/a.png'),
          TransferHistoryFile(fileName: 'b.txt', fileSize: 3, fileType: FileType.text, path: null),
        ],
        isMessage: false,
        timestamp: DateTime.utc(2024, 1, 2, 3, 4, 5),
      );

      final restored = TransferHistoryEntry.fromJson(entry.toJson());

      expect(restored.id, entry.id);
      expect(restored.direction, TransferDirection.sent);
      expect(restored.status, TransferStatus.completed);
      expect(restored.peerAlias, 'Phone');
      expect(restored.peerFingerprint, 'fp');
      expect(restored.peerIp, '192.168.1.2');
      expect(restored.peerPort, 53317);
      expect(restored.peerHttps, isTrue);
      expect(restored.files.length, 2);
      expect(restored.files[0].fileName, 'a.png');
      expect(restored.files[0].path, '/tmp/a.png');
      expect(restored.files[1].path, isNull);
      expect(restored.timestamp, entry.timestamp);
      expect(restored, entry); // dart_mappable deep equality
    });

    test('json roundtrip of received entry', () {
      final entry = TransferHistoryEntry(
        id: 's2',
        direction: TransferDirection.received,
        status: TransferStatus.declined,
        peerAlias: 'PC',
        peerFingerprint: null,
        peerIp: null,
        peerPort: 0,
        peerHttps: false,
        files: const [],
        isMessage: true,
        timestamp: DateTime.utc(2024),
      );

      final restored = TransferHistoryEntry.fromJson(entry.toJson());
      expect(restored, entry);
      expect(restored.isMessage, isTrue);
    });
  });
}
