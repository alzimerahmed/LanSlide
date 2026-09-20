// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'trusted_device.dart';

class TrustedDeviceMapper extends ClassMapperBase<TrustedDevice> {
  TrustedDeviceMapper._();

  static TrustedDeviceMapper? _instance;
  static TrustedDeviceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TrustedDeviceMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TrustedDevice';

  static String _$fingerprint(TrustedDevice v) => v.fingerprint;
  static const Field<TrustedDevice, String> _f$fingerprint = Field(
    'fingerprint',
    _$fingerprint,
  );
  static String _$alias(TrustedDevice v) => v.alias;
  static const Field<TrustedDevice, String> _f$alias = Field('alias', _$alias);
  static bool _$alwaysAccept(TrustedDevice v) => v.alwaysAccept;
  static const Field<TrustedDevice, bool> _f$alwaysAccept = Field(
    'alwaysAccept',
    _$alwaysAccept,
    opt: true,
    def: false,
  );
  static DateTime _$addedAt(TrustedDevice v) => v.addedAt;
  static const Field<TrustedDevice, DateTime> _f$addedAt = Field(
    'addedAt',
    _$addedAt,
  );

  @override
  final MappableFields<TrustedDevice> fields = const {
    #fingerprint: _f$fingerprint,
    #alias: _f$alias,
    #alwaysAccept: _f$alwaysAccept,
    #addedAt: _f$addedAt,
  };

  static TrustedDevice _instantiate(DecodingData data) {
    return TrustedDevice(
      fingerprint: data.dec(_f$fingerprint),
      alias: data.dec(_f$alias),
      alwaysAccept: data.dec(_f$alwaysAccept),
      addedAt: data.dec(_f$addedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TrustedDevice fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TrustedDevice>(map);
  }

  static TrustedDevice deserialize(String json) {
    return ensureInitialized().decodeJson<TrustedDevice>(json);
  }
}

mixin TrustedDeviceMappable {
  String serialize() {
    return TrustedDeviceMapper.ensureInitialized().encodeJson<TrustedDevice>(
      this as TrustedDevice,
    );
  }

  Map<String, dynamic> toJson() {
    return TrustedDeviceMapper.ensureInitialized().encodeMap<TrustedDevice>(
      this as TrustedDevice,
    );
  }

  TrustedDeviceCopyWith<TrustedDevice, TrustedDevice, TrustedDevice>
  get copyWith => _TrustedDeviceCopyWithImpl<TrustedDevice, TrustedDevice>(
    this as TrustedDevice,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TrustedDeviceMapper.ensureInitialized().stringifyValue(
      this as TrustedDevice,
    );
  }

  @override
  bool operator ==(Object other) {
    return TrustedDeviceMapper.ensureInitialized().equalsValue(
      this as TrustedDevice,
      other,
    );
  }

  @override
  int get hashCode {
    return TrustedDeviceMapper.ensureInitialized().hashValue(
      this as TrustedDevice,
    );
  }
}

extension TrustedDeviceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TrustedDevice, $Out> {
  TrustedDeviceCopyWith<$R, TrustedDevice, $Out> get $asTrustedDevice =>
      $base.as((v, t, t2) => _TrustedDeviceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TrustedDeviceCopyWith<$R, $In extends TrustedDevice, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? fingerprint,
    String? alias,
    bool? alwaysAccept,
    DateTime? addedAt,
  });
  TrustedDeviceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TrustedDeviceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TrustedDevice, $Out>
    implements TrustedDeviceCopyWith<$R, TrustedDevice, $Out> {
  _TrustedDeviceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TrustedDevice> $mapper =
      TrustedDeviceMapper.ensureInitialized();
  @override
  $R call({
    String? fingerprint,
    String? alias,
    bool? alwaysAccept,
    DateTime? addedAt,
  }) => $apply(
    FieldCopyWithData({
      if (fingerprint != null) #fingerprint: fingerprint,
      if (alias != null) #alias: alias,
      if (alwaysAccept != null) #alwaysAccept: alwaysAccept,
      if (addedAt != null) #addedAt: addedAt,
    }),
  );
  @override
  TrustedDevice $make(CopyWithData data) => TrustedDevice(
    fingerprint: data.get(#fingerprint, or: $value.fingerprint),
    alias: data.get(#alias, or: $value.alias),
    alwaysAccept: data.get(#alwaysAccept, or: $value.alwaysAccept),
    addedAt: data.get(#addedAt, or: $value.addedAt),
  );

  @override
  TrustedDeviceCopyWith<$R2, TrustedDevice, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TrustedDeviceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

