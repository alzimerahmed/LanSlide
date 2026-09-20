import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

part 'android_channel.mapper.dart';

const _methodChannel = MethodChannel('com.alzimerahmed.lanslide/localsend');
final _logger = Logger('AndroidSaf');

/// From Android 10 and above, we need to use the Storage Access Framework (SAF) to access files due to the scoped storage.
/// SAF itself is available from Android 4.4 (API level 19).
/// We implemented our own algorithm to build encode and decode content URIs.
/// Older versions might also work but the encoded content URI is not guaranteed to work with our algorithm.
const contentUriMinSdk = 27;

Future<PickDirectoryResult?> pickDirectoryAndroid() async {
  final result = await _methodChannel.invokeMethod<Map>('pickDirectory');
  if (result == null) {
    return null;
  }

  return PickDirectoryResultMapper.fromJson({
    'directoryUri': result['directoryUri'],
    'files': (result['files'] as List).map((e) => FileInfoMapper.fromJson((e as Map).cast<String, dynamic>())).toList(),
  });
}

Future<String?> pickDirectoryPathAndroid() async {
  final result = await _methodChannel.invokeMethod<String>('pickDirectoryPath');
  return result;
}

Future<List<FileInfo>?> pickFilesAndroid() async {
  final result = await _methodChannel.invokeMethod<List>('pickFiles');
  if (result == null) {
    return null;
  }

  return result.map((e) => FileInfoMapper.fromJson((e as Map).cast<String, dynamic>())).toList();
}

/// Returns the global "Download" directory, e.g. /storage/emulated/0/Download.
Future<String?> getDownloadsDirectoryAndroid() async {
  try {
    return await _methodChannel.invokeMethod<String>('getDownloadsDirectory');
  } catch (e) {
    _logger.warning('Could not get downloads directory', e);
    return null;
  }
}

Future<bool> getSystemAnimationsStatusAndroid() async {
  return await _methodChannel.invokeMethod('isAnimationsEnabled') ?? true;
}

/// Requests the "Nearby devices" permission gating local network access on Android 17+.
/// Returns true when granted or when running on an older Android version.
Future<bool> requestLocalNetworkPermissionAndroid() async {
  try {
    return await _methodChannel.invokeMethod<bool>('requestLocalNetworkPermission') ?? false;
  } catch (e) {
    _logger.warning('Could not request local network permission', e);
    return false;
  }
}

Future<void> openContentUri({
  required String uri,
}) async {
  _logger.info('Opening content URI: $uri');
  await _methodChannel.invokeMethod('openContentUri', {
    'uri': uri,
  });
}

/// Tells MainActivity that the Dart side is now subscribed to the share_handler media stream,
/// so share intents that were held back during app start can be replayed.
Future<void> flushPendingShareIntentsAndroid() async {
  try {
    await _methodChannel.invokeMethod('shareIntentReady');
  } catch (e) {
    _logger.warning('Could not flush pending share intents', e);
  }
}

Future<void> openGallery() async {
  _logger.info('Opening gallery');
  await _methodChannel.invokeMethod('openGallery');
}

/// Guidance for OEM battery killers that kill background apps (Task 3.17).
/// Plain constant on purpose — no i18n edits allowed for this task.
const dontKillMyAppUrl = 'https://dontkillmyapp.com/';

/// Registers a handler for methods invoked from the Kotlin side (e.g. the
/// Quick Settings tile requesting a receive-mode toggle).
void setAndroidChannelHandler(Future<dynamic> Function(MethodCall call) handler) {
  _methodChannel.setMethodCallHandler(handler);
}

/// Reports the receive-server state to Android: keeps the Quick Settings tile in
/// sync and starts/stops the receive foreground service (Task 3.17).
Future<void> notifyServerStateAndroid({required bool running}) async {
  try {
    await _methodChannel.invokeMethod('notifyServerState', {'running': running});
  } catch (e) {
    _logger.warning('Could not notify server state', e);
  }
}

/// Returns and clears the pending "stop receive" request made by the QS tile
/// (the tile only sends this extra when receive should be turned off; turning
/// it on is handled by the app's auto-start).
Future<bool> consumePendingStopReceiveAndroid() async {
  try {
    return await _methodChannel.invokeMethod<bool>('consumePendingStopReceive') ?? false;
  } catch (e) {
    _logger.warning('Could not consume pending stop-receive request', e);
    return false;
  }
}

/// Whether the app is exempt from battery optimizations (Doze / OEM killers).
Future<bool> isIgnoringBatteryOptimizationsAndroid() async {
  try {
    return await _methodChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ?? false;
  } catch (e) {
    _logger.warning('Could not check battery optimization state', e);
    return false;
  }
}

/// Opens the system dialog asking the user to exempt LanSlide from battery
/// optimization. UI hook should live in the settings page (server section) —
/// not wired here to avoid touching files owned by another agent.
Future<void> requestIgnoreBatteryOptimizationsAndroid() async {
  try {
    await _methodChannel.invokeMethod('requestIgnoreBatteryOptimizations');
  } catch (e) {
    _logger.warning('Could not request battery optimization exemption', e);
  }
}

/// Result of a direct MediaStore insert (gallery save without the cache copy).
@MappableClass()
class MediaStoreFileResult with MediaStoreFileResultMappable {
  /// The content URI of the inserted MediaStore row (for the receive history).
  final String uri;

  /// A writable file descriptor (parcel "w" mode) pointing at the MediaStore
  /// entry, so the file can be streamed directly into the gallery.
  final int fileDescriptor;

  MediaStoreFileResult({
    required this.uri,
    required this.fileDescriptor,
  });
}

/// Inserts a pending row into MediaStore (Images/Video collection depending on
/// [mimeType]) and returns a writable file descriptor for it.
///
/// This enables saving received photos/videos straight into the gallery without
/// the intermediate cache-file copy that `Gal.putImage/putVideo` performs.
///
/// REQUIRED KOTLIN FOLLOW-UP (not implemented here — app/android/ is owned by
/// another agent). Add to MainActivity.kt's method-channel handler:
///
/// ```kotlin
/// "createMediaStoreFile" -> {
///     val name = call.argument<String>("fileName")!!
///     val mime = call.argument<String>("mimeType")!!
///     val collection = if (mime.startsWith("video/"))
///         MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
///     else
///         MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
///     val values = ContentValues().apply {
///         put(MediaStore.MediaColumns.DISPLAY_NAME, name)
///         put(MediaStore.MediaColumns.MIME_TYPE, mime)
///         put(MediaStore.MediaColumns.RELATIVE_PATH,
///             if (mime.startsWith("video/")) Environment.DIRECTORY_MOVIES else Environment.DIRECTORY_PICTURES)
///         put(MediaStore.MediaColumns.IS_PENDING, 1)
///     }
///     val resolver = applicationContext.contentResolver
///     val uri = resolver.insert(collection, values) ?: run { result.success(null); return@setMethodCallHandler }
///     val fd = resolver.openFileDescriptor(uri, "w")!!.detachFd()
///     result.success(mapOf("uri" to uri.toString(), "fileDescriptor" to fd))
/// }
/// ```
///
/// After the Rust server has written the bytes, the row must be published
/// (IS_PENDING = 0) via a companion method, e.g.:
///
/// ```kotlin
/// "finishMediaStoreFile" -> {
///     val uri = Uri.parse(call.argument<String>("uri")!!)
///     val values = ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 0) }
///     applicationContext.contentResolver.update(uri, values, null, null)
///     result.success(null)
/// }
/// ```
///
/// Wiring: `prepareFileSaveTarget` in packages/localsend_isolates should use
/// this instead of the cache directory when `saveToGallery` is true, and call
/// `finishMediaStoreFileAndroid` after the write completes. Requires API 29+
/// (scoped storage); below that, keep the existing Gal-based path.
Future<MediaStoreFileResult?> createMediaStoreFileAndroid({
  required String fileName,
  required String mimeType,
}) async {
  try {
    final result = await _methodChannel.invokeMethod<Map>('createMediaStoreFile', {
      'fileName': fileName,
      'mimeType': mimeType,
    });
    if (result == null) {
      return null;
    }
    return MediaStoreFileResult(
      uri: result['uri'] as String,
      fileDescriptor: result['fileDescriptor'] as int,
    );
  } catch (e) {
    _logger.warning('Could not create MediaStore file', e);
    return null;
  }
}

/// Publishes a pending MediaStore row after its bytes have been written.
/// Requires the `finishMediaStoreFile` Kotlin method documented in
/// [createMediaStoreFileAndroid].
Future<void> finishMediaStoreFileAndroid({required String uri}) async {
  try {
    await _methodChannel.invokeMethod('finishMediaStoreFile', {'uri': uri});
  } catch (e) {
    _logger.warning('Could not finish MediaStore file', e);
  }
}

@MappableClass()
class PickDirectoryResult with PickDirectoryResultMappable {
  final String directoryUri;
  final List<FileInfo> files;

  PickDirectoryResult({
    required this.directoryUri,
    required this.files,
  });
}

@MappableClass()
class FileInfo with FileInfoMappable {
  final String name;
  final int size;
  final String uri;

  /// RFC 3339 in UTC. Null when the document provider does not know it.
  final String? lastModified;

  FileInfo({
    required this.name,
    required this.size,
    required this.uri,
    required this.lastModified,
  });
}
