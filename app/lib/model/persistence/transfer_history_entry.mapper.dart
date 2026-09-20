// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'transfer_history_entry.dart';

class TransferDirectionMapper extends EnumMapper<TransferDirection> {
  TransferDirectionMapper._();

  static TransferDirectionMapper? _instance;
  static TransferDirectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TransferDirectionMapper._());
    }
    return _instance!;
  }

  static TransferDirection fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TransferDirection decode(dynamic value) {
    switch (value) {
      case r'sent':
        return TransferDirection.sent;
      case r'received':
        return TransferDirection.received;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TransferDirection self) {
    switch (self) {
      case TransferDirection.sent:
        return r'sent';
      case TransferDirection.received:
        return r'received';
    }
  }
}

extension TransferDirectionMapperExtension on TransferDirection {
  String toValue() {
    TransferDirectionMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TransferDirection>(this) as String;
  }
}

class TransferStatusMapper extends EnumMapper<TransferStatus> {
  TransferStatusMapper._();

  static TransferStatusMapper? _instance;
  static TransferStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TransferStatusMapper._());
    }
    return _instance!;
  }

  static TransferStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TransferStatus decode(dynamic value) {
    switch (value) {
      case r'completed':
        return TransferStatus.completed;
      case r'failed':
        return TransferStatus.failed;
      case r'canceled':
        return TransferStatus.canceled;
      case r'declined':
        return TransferStatus.declined;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TransferStatus self) {
    switch (self) {
      case TransferStatus.completed:
        return r'completed';
      case TransferStatus.failed:
        return r'failed';
      case TransferStatus.canceled:
        return r'canceled';
      case TransferStatus.declined:
        return r'declined';
    }
  }
}

extension TransferStatusMapperExtension on TransferStatus {
  String toValue() {
    TransferStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TransferStatus>(this) as String;
  }
}

class TransferHistoryFileMapper extends ClassMapperBase<TransferHistoryFile> {
  TransferHistoryFileMapper._();

  static TransferHistoryFileMapper? _instance;
  static TransferHistoryFileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TransferHistoryFileMapper._());
      FileTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TransferHistoryFile';

  static String _$fileName(TransferHistoryFile v) => v.fileName;
  static const Field<TransferHistoryFile, String> _f$fileName = Field(
    'fileName',
    _$fileName,
  );
  static int _$fileSize(TransferHistoryFile v) => v.fileSize;
  static const Field<TransferHistoryFile, int> _f$fileSize = Field(
    'fileSize',
    _$fileSize,
  );
  static FileType _$fileType(TransferHistoryFile v) => v.fileType;
  static const Field<TransferHistoryFile, FileType> _f$fileType = Field(
    'fileType',
    _$fileType,
  );
  static String? _$path(TransferHistoryFile v) => v.path;
  static const Field<TransferHistoryFile, String> _f$path = Field(
    'path',
    _$path,
  );

  @override
  final MappableFields<TransferHistoryFile> fields = const {
    #fileName: _f$fileName,
    #fileSize: _f$fileSize,
    #fileType: _f$fileType,
    #path: _f$path,
  };

  static TransferHistoryFile _instantiate(DecodingData data) {
    return TransferHistoryFile(
      fileName: data.dec(_f$fileName),
      fileSize: data.dec(_f$fileSize),
      fileType: data.dec(_f$fileType),
      path: data.dec(_f$path),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TransferHistoryFile fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TransferHistoryFile>(map);
  }

  static TransferHistoryFile deserialize(String json) {
    return ensureInitialized().decodeJson<TransferHistoryFile>(json);
  }
}

mixin TransferHistoryFileMappable {
  String serialize() {
    return TransferHistoryFileMapper.ensureInitialized()
        .encodeJson<TransferHistoryFile>(this as TransferHistoryFile);
  }

  Map<String, dynamic> toJson() {
    return TransferHistoryFileMapper.ensureInitialized()
        .encodeMap<TransferHistoryFile>(this as TransferHistoryFile);
  }

  TransferHistoryFileCopyWith<
    TransferHistoryFile,
    TransferHistoryFile,
    TransferHistoryFile
  >
  get copyWith =>
      _TransferHistoryFileCopyWithImpl<
        TransferHistoryFile,
        TransferHistoryFile
      >(this as TransferHistoryFile, $identity, $identity);
  @override
  String toString() {
    return TransferHistoryFileMapper.ensureInitialized().stringifyValue(
      this as TransferHistoryFile,
    );
  }

  @override
  bool operator ==(Object other) {
    return TransferHistoryFileMapper.ensureInitialized().equalsValue(
      this as TransferHistoryFile,
      other,
    );
  }

  @override
  int get hashCode {
    return TransferHistoryFileMapper.ensureInitialized().hashValue(
      this as TransferHistoryFile,
    );
  }
}

extension TransferHistoryFileValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TransferHistoryFile, $Out> {
  TransferHistoryFileCopyWith<$R, TransferHistoryFile, $Out>
  get $asTransferHistoryFile => $base.as(
    (v, t, t2) => _TransferHistoryFileCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TransferHistoryFileCopyWith<
  $R,
  $In extends TransferHistoryFile,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? fileName, int? fileSize, FileType? fileType, String? path});
  TransferHistoryFileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TransferHistoryFileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TransferHistoryFile, $Out>
    implements TransferHistoryFileCopyWith<$R, TransferHistoryFile, $Out> {
  _TransferHistoryFileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TransferHistoryFile> $mapper =
      TransferHistoryFileMapper.ensureInitialized();
  @override
  $R call({
    String? fileName,
    int? fileSize,
    FileType? fileType,
    Object? path = $none,
  }) => $apply(
    FieldCopyWithData({
      if (fileName != null) #fileName: fileName,
      if (fileSize != null) #fileSize: fileSize,
      if (fileType != null) #fileType: fileType,
      if (path != $none) #path: path,
    }),
  );
  @override
  TransferHistoryFile $make(CopyWithData data) => TransferHistoryFile(
    fileName: data.get(#fileName, or: $value.fileName),
    fileSize: data.get(#fileSize, or: $value.fileSize),
    fileType: data.get(#fileType, or: $value.fileType),
    path: data.get(#path, or: $value.path),
  );

  @override
  TransferHistoryFileCopyWith<$R2, TransferHistoryFile, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TransferHistoryFileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TransferHistoryEntryMapper extends ClassMapperBase<TransferHistoryEntry> {
  TransferHistoryEntryMapper._();

  static TransferHistoryEntryMapper? _instance;
  static TransferHistoryEntryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TransferHistoryEntryMapper._());
      TransferDirectionMapper.ensureInitialized();
      TransferStatusMapper.ensureInitialized();
      TransferHistoryFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TransferHistoryEntry';

  static String _$id(TransferHistoryEntry v) => v.id;
  static const Field<TransferHistoryEntry, String> _f$id = Field('id', _$id);
  static TransferDirection _$direction(TransferHistoryEntry v) => v.direction;
  static const Field<TransferHistoryEntry, TransferDirection> _f$direction =
      Field('direction', _$direction);
  static TransferStatus _$status(TransferHistoryEntry v) => v.status;
  static const Field<TransferHistoryEntry, TransferStatus> _f$status = Field(
    'status',
    _$status,
  );
  static String _$peerAlias(TransferHistoryEntry v) => v.peerAlias;
  static const Field<TransferHistoryEntry, String> _f$peerAlias = Field(
    'peerAlias',
    _$peerAlias,
  );
  static String? _$peerFingerprint(TransferHistoryEntry v) => v.peerFingerprint;
  static const Field<TransferHistoryEntry, String> _f$peerFingerprint = Field(
    'peerFingerprint',
    _$peerFingerprint,
  );
  static String? _$peerIp(TransferHistoryEntry v) => v.peerIp;
  static const Field<TransferHistoryEntry, String> _f$peerIp = Field(
    'peerIp',
    _$peerIp,
  );
  static int _$peerPort(TransferHistoryEntry v) => v.peerPort;
  static const Field<TransferHistoryEntry, int> _f$peerPort = Field(
    'peerPort',
    _$peerPort,
  );
  static bool _$peerHttps(TransferHistoryEntry v) => v.peerHttps;
  static const Field<TransferHistoryEntry, bool> _f$peerHttps = Field(
    'peerHttps',
    _$peerHttps,
  );
  static List<TransferHistoryFile> _$files(TransferHistoryEntry v) => v.files;
  static const Field<TransferHistoryEntry, List<TransferHistoryFile>> _f$files =
      Field('files', _$files);
  static bool _$isMessage(TransferHistoryEntry v) => v.isMessage;
  static const Field<TransferHistoryEntry, bool> _f$isMessage = Field(
    'isMessage',
    _$isMessage,
  );
  static DateTime _$timestamp(TransferHistoryEntry v) => v.timestamp;
  static const Field<TransferHistoryEntry, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );

  @override
  final MappableFields<TransferHistoryEntry> fields = const {
    #id: _f$id,
    #direction: _f$direction,
    #status: _f$status,
    #peerAlias: _f$peerAlias,
    #peerFingerprint: _f$peerFingerprint,
    #peerIp: _f$peerIp,
    #peerPort: _f$peerPort,
    #peerHttps: _f$peerHttps,
    #files: _f$files,
    #isMessage: _f$isMessage,
    #timestamp: _f$timestamp,
  };

  static TransferHistoryEntry _instantiate(DecodingData data) {
    return TransferHistoryEntry(
      id: data.dec(_f$id),
      direction: data.dec(_f$direction),
      status: data.dec(_f$status),
      peerAlias: data.dec(_f$peerAlias),
      peerFingerprint: data.dec(_f$peerFingerprint),
      peerIp: data.dec(_f$peerIp),
      peerPort: data.dec(_f$peerPort),
      peerHttps: data.dec(_f$peerHttps),
      files: data.dec(_f$files),
      isMessage: data.dec(_f$isMessage),
      timestamp: data.dec(_f$timestamp),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TransferHistoryEntry fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TransferHistoryEntry>(map);
  }

  static TransferHistoryEntry deserialize(String json) {
    return ensureInitialized().decodeJson<TransferHistoryEntry>(json);
  }
}

mixin TransferHistoryEntryMappable {
  String serialize() {
    return TransferHistoryEntryMapper.ensureInitialized()
        .encodeJson<TransferHistoryEntry>(this as TransferHistoryEntry);
  }

  Map<String, dynamic> toJson() {
    return TransferHistoryEntryMapper.ensureInitialized()
        .encodeMap<TransferHistoryEntry>(this as TransferHistoryEntry);
  }

  TransferHistoryEntryCopyWith<
    TransferHistoryEntry,
    TransferHistoryEntry,
    TransferHistoryEntry
  >
  get copyWith =>
      _TransferHistoryEntryCopyWithImpl<
        TransferHistoryEntry,
        TransferHistoryEntry
      >(this as TransferHistoryEntry, $identity, $identity);
  @override
  String toString() {
    return TransferHistoryEntryMapper.ensureInitialized().stringifyValue(
      this as TransferHistoryEntry,
    );
  }

  @override
  bool operator ==(Object other) {
    return TransferHistoryEntryMapper.ensureInitialized().equalsValue(
      this as TransferHistoryEntry,
      other,
    );
  }

  @override
  int get hashCode {
    return TransferHistoryEntryMapper.ensureInitialized().hashValue(
      this as TransferHistoryEntry,
    );
  }
}

extension TransferHistoryEntryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TransferHistoryEntry, $Out> {
  TransferHistoryEntryCopyWith<$R, TransferHistoryEntry, $Out>
  get $asTransferHistoryEntry => $base.as(
    (v, t, t2) => _TransferHistoryEntryCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TransferHistoryEntryCopyWith<
  $R,
  $In extends TransferHistoryEntry,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    TransferHistoryFile,
    TransferHistoryFileCopyWith<$R, TransferHistoryFile, TransferHistoryFile>
  >
  get files;
  $R call({
    String? id,
    TransferDirection? direction,
    TransferStatus? status,
    String? peerAlias,
    String? peerFingerprint,
    String? peerIp,
    int? peerPort,
    bool? peerHttps,
    List<TransferHistoryFile>? files,
    bool? isMessage,
    DateTime? timestamp,
  });
  TransferHistoryEntryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TransferHistoryEntryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TransferHistoryEntry, $Out>
    implements TransferHistoryEntryCopyWith<$R, TransferHistoryEntry, $Out> {
  _TransferHistoryEntryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TransferHistoryEntry> $mapper =
      TransferHistoryEntryMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    TransferHistoryFile,
    TransferHistoryFileCopyWith<$R, TransferHistoryFile, TransferHistoryFile>
  >
  get files => ListCopyWith(
    $value.files,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(files: v),
  );
  @override
  $R call({
    String? id,
    TransferDirection? direction,
    TransferStatus? status,
    String? peerAlias,
    Object? peerFingerprint = $none,
    Object? peerIp = $none,
    int? peerPort,
    bool? peerHttps,
    List<TransferHistoryFile>? files,
    bool? isMessage,
    DateTime? timestamp,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (direction != null) #direction: direction,
      if (status != null) #status: status,
      if (peerAlias != null) #peerAlias: peerAlias,
      if (peerFingerprint != $none) #peerFingerprint: peerFingerprint,
      if (peerIp != $none) #peerIp: peerIp,
      if (peerPort != null) #peerPort: peerPort,
      if (peerHttps != null) #peerHttps: peerHttps,
      if (files != null) #files: files,
      if (isMessage != null) #isMessage: isMessage,
      if (timestamp != null) #timestamp: timestamp,
    }),
  );
  @override
  TransferHistoryEntry $make(CopyWithData data) => TransferHistoryEntry(
    id: data.get(#id, or: $value.id),
    direction: data.get(#direction, or: $value.direction),
    status: data.get(#status, or: $value.status),
    peerAlias: data.get(#peerAlias, or: $value.peerAlias),
    peerFingerprint: data.get(#peerFingerprint, or: $value.peerFingerprint),
    peerIp: data.get(#peerIp, or: $value.peerIp),
    peerPort: data.get(#peerPort, or: $value.peerPort),
    peerHttps: data.get(#peerHttps, or: $value.peerHttps),
    files: data.get(#files, or: $value.files),
    isMessage: data.get(#isMessage, or: $value.isMessage),
    timestamp: data.get(#timestamp, or: $value.timestamp),
  );

  @override
  TransferHistoryEntryCopyWith<$R2, TransferHistoryEntry, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TransferHistoryEntryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

