import 'package:dart_mappable/dart_mappable.dart';

part 'trusted_device.mapper.dart';

/// A device trusted by its certificate fingerprint.
///
/// The fingerprint is the mTLS certificate fingerprint of the peer and is
/// therefore not spoofable (unless encryption is disabled, in which case the
/// self-reported fingerprint is used as fallback).
@MappableClass()
class TrustedDevice with TrustedDeviceMappable {
  final String fingerprint;
  final String alias;

  /// If true, incoming transfer requests from this device are accepted
  /// automatically without showing the receive dialog.
  final bool alwaysAccept;

  final DateTime addedAt;

  const TrustedDevice({
    required this.fingerprint,
    required this.alias,
    this.alwaysAccept = false,
    required this.addedAt,
  });

  /// Finds the trusted device entry for the given fingerprint, if any.
  static TrustedDevice? find(List<TrustedDevice> devices, String fingerprint) {
    for (final device in devices) {
      if (device.fingerprint == fingerprint) {
        return device;
      }
    }
    return null;
  }

  /// Whether an incoming request from [fingerprint] should be auto-accepted.
  static bool shouldAutoAccept(List<TrustedDevice> devices, String fingerprint) {
    return find(devices, fingerprint)?.alwaysAccept ?? false;
  }

  static const fromJson = TrustedDeviceMapper.fromJson;
}
