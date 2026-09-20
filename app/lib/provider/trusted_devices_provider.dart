import 'package:localsend_app/model/persistence/trusted_device.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// This provider stores the list of trusted devices (fingerprint allowlist).
/// It automatically saves the list to the device's storage.
final trustedDevicesProvider = ReduxProvider<TrustedDevicesService, List<TrustedDevice>>((ref) {
  return TrustedDevicesService(ref.read(persistenceProvider));
});

class TrustedDevicesService extends ReduxNotifier<List<TrustedDevice>> {
  final PersistenceService _persistence;

  TrustedDevicesService(this._persistence);

  @override
  List<TrustedDevice> init() => _persistence.getTrustedDevices();
}

/// Adds a trusted device. If a device with the same fingerprint already
/// exists, the state is unchanged.
class AddTrustedDeviceAction extends AsyncReduxAction<TrustedDevicesService, List<TrustedDevice>> {
  final TrustedDevice device;

  AddTrustedDeviceAction(this.device);

  @override
  Future<List<TrustedDevice>> reduce() async {
    if (state.any((e) => e.fingerprint == device.fingerprint)) {
      return state;
    }
    final updated = List<TrustedDevice>.unmodifiable([...state, device]);
    await notifier._persistence.setTrustedDevices(updated);
    return updated;
  }
}

/// Updates a trusted device (e.g. toggling "always accept").
class UpdateTrustedDeviceAction extends AsyncReduxAction<TrustedDevicesService, List<TrustedDevice>> {
  final TrustedDevice device;

  UpdateTrustedDeviceAction(this.device);

  @override
  Future<List<TrustedDevice>> reduce() async {
    final index = state.indexWhere((e) => e.fingerprint == device.fingerprint);
    if (index == -1) {
      return state;
    }
    final updated = List<TrustedDevice>.unmodifiable(
      <TrustedDevice>[
        ...state,
      ]..replaceRange(index, index + 1, [device]),
    );
    await notifier._persistence.setTrustedDevices(updated);
    return updated;
  }
}

/// Removes a trusted device by fingerprint.
class RemoveTrustedDeviceAction extends AsyncReduxAction<TrustedDevicesService, List<TrustedDevice>> {
  final String fingerprint;

  RemoveTrustedDeviceAction({required this.fingerprint});

  @override
  Future<List<TrustedDevice>> reduce() async {
    final index = state.indexWhere((e) => e.fingerprint == fingerprint);
    if (index == -1) {
      return state;
    }
    final updated = List<TrustedDevice>.unmodifiable(
      <TrustedDevice>[
        ...state,
      ]..removeAt(index),
    );
    await notifier._persistence.setTrustedDevices(updated);
    return updated;
  }
}
