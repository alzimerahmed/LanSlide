import 'package:localsend_app/model/persistence/transfer_history_entry.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

const _maxTransferHistoryEntries = 100;

/// This provider stores the unified transfer history (sent and received
/// transfers, completed / failed / canceled).
/// It automatically saves the history to the device's storage.
final transferHistoryProvider = ReduxProvider<TransferHistoryService, List<TransferHistoryEntry>>((ref) {
  return TransferHistoryService(ref.read(persistenceProvider));
});

class TransferHistoryService extends ReduxNotifier<List<TransferHistoryEntry>> {
  final PersistenceService _persistence;

  TransferHistoryService(this._persistence);

  @override
  List<TransferHistoryEntry> init() => _persistence.getTransferHistory();
}

/// Adds a transfer history entry (newest first, capped).
class AddTransferHistoryEntryAction extends AsyncReduxAction<TransferHistoryService, List<TransferHistoryEntry>> {
  final TransferHistoryEntry entry;

  AddTransferHistoryEntryAction(this.entry);

  @override
  Future<List<TransferHistoryEntry>> reduce() async {
    final updated = [entry, ...state.where((e) => e.id != entry.id)].take(_maxTransferHistoryEntries).toList();
    await notifier._persistence.setTransferHistory(updated);
    return updated;
  }
}

/// Removes a transfer history entry.
class RemoveTransferHistoryEntryAction extends AsyncReduxAction<TransferHistoryService, List<TransferHistoryEntry>> {
  final String entryId;

  RemoveTransferHistoryEntryAction(this.entryId);

  @override
  Future<List<TransferHistoryEntry>> reduce() async {
    final updated = state.where((e) => e.id != entryId).toList();
    await notifier._persistence.setTransferHistory(updated);
    return updated;
  }
}

/// Removes all transfer history entries.
class RemoveAllTransferHistoryEntriesAction extends AsyncReduxAction<TransferHistoryService, List<TransferHistoryEntry>> {
  @override
  Future<List<TransferHistoryEntry>> reduce() async {
    await notifier._persistence.setTransferHistory([]);
    return [];
  }
}
