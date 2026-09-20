import 'package:localsend_app/model/persistence/transfer_history_entry.dart';
import 'package:localsend_app/model/persistence/trusted_device.dart';
import 'package:localsend_app/provider/transfer_history_provider.dart';
import 'package:localsend_isolates/model/file_type.dart';
import 'package:mockito/mockito.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:test/test.dart';

import '../../mocks.mocks.dart';

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

  group('TransferHistory reducers', () {
    late MockPersistenceService persistence;

    setUp(() {
      persistence = MockPersistenceService();
      when(persistence.getTransferHistory()).thenReturn([]);
    });

    TransferHistoryEntry makeEntry(String id, {TransferStatus status = TransferStatus.completed}) {
      return TransferHistoryEntry(
        id: id,
        direction: TransferDirection.sent,
        status: status,
        peerAlias: 'Peer',
        peerFingerprint: 'fp',
        peerIp: '192.168.1.2',
        peerPort: 53317,
        peerHttps: true,
        files: const [],
        isMessage: false,
        timestamp: DateTime.utc(2024),
      );
    }

    test('add inserts newest first and dedupes by id', () async {
      final service = ReduxNotifier.test(
        redux: TransferHistoryService(persistence),
        initialState: [makeEntry('1'), makeEntry('2')],
      );

      await service.dispatchAsync(AddTransferHistoryEntryAction(makeEntry('3')));
      expect(service.state.map((e) => e.id), ['3', '1', '2']);

      // Same id replaces the old entry instead of duplicating.
      await service.dispatchAsync(AddTransferHistoryEntryAction(makeEntry('1', status: TransferStatus.failed)));
      expect(service.state.map((e) => e.id), ['1', '3', '2']);
      expect(service.state.first.status, TransferStatus.failed);
      verify(persistence.setTransferHistory(argThat(anything))).called(2);
    });

    test('add caps the history at 100 entries', () async {
      final service = ReduxNotifier.test(
        redux: TransferHistoryService(persistence),
        initialState: List.generate(100, (i) => makeEntry(i.toString())),
      );

      await service.dispatchAsync(AddTransferHistoryEntryAction(makeEntry('new')));

      expect(service.state.length, 100);
      expect(service.state.first.id, 'new');
      expect(service.state.any((e) => e.id == '99'), isFalse); // oldest dropped
    });

    test('remove and removeAll persist', () async {
      final service = ReduxNotifier.test(
        redux: TransferHistoryService(persistence),
        initialState: [makeEntry('1'), makeEntry('2')],
      );

      await service.dispatchAsync(RemoveTransferHistoryEntryAction('1'));
      expect(service.state.map((e) => e.id), ['2']);
      verify(persistence.setTransferHistory([makeEntry('2')])).called(1);

      await service.dispatchAsync(RemoveAllTransferHistoryEntriesAction());
      expect(service.state, isEmpty);
      verify(persistence.setTransferHistory([])).called(1);
    });
  });
}
