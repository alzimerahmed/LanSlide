#![cfg(feature = "full")]

//! Protocol-compat regression tests.
//!
//! These tests lock the wire format of the protocol v2 DTOs against the
//! upstream LocalSend protocol v2 spec
//! (https://github.com/localsend/protocol/blob/main/v2/README.md).
//!
//! If any of these tests fail after a change, LanSlide and upstream LocalSend
//! would no longer be able to talk to each other. Treat a failure as a
//! protocol break, not a test to update blindly.

use localsend::http::dto_v2::{
    InfoResponseDtoV2, PrepareDownloadResponseDtoV2, PrepareUploadRequestDtoV2,
    PrepareUploadResponseDtoV2, RegisterDtoV2,
};
use localsend::model::discovery::{DeviceType, MulticastMessageV2, ProtocolType};
use localsend::model::transfer::{FileDto, FileMetadata};
use serde_json::{json, Value};
use std::collections::HashMap;

/// Builds a `FileDto` with every optional field populated.
fn full_file_dto(id: &str) -> FileDto {
    FileDto {
        id: id.to_string(),
        file_name: "holiday photo.jpg".to_string(),
        size: 1_048_576,
        file_type: "image/jpeg".to_string(),
        sha256: Some("deadbeef".to_string()),
        preview: Some("data:image/png;base64,iVBOR".to_string()),
        metadata: Some(FileMetadata {
            modified: Some("2024-01-02T03:04:05.678Z".to_string()),
            accessed: Some("2024-01-02T03:04:06.000Z".to_string()),
        }),
    }
}

/// Builds a sender `RegisterDtoV2` with every field populated.
fn full_register_dto() -> RegisterDtoV2 {
    RegisterDtoV2 {
        alias: "Secret Banana".to_string(),
        version: "2.2".to_string(),
        device_model: Some("Windows".to_string()),
        device_type: Some(DeviceType::Desktop),
        fingerprint: "random string".to_string(),
        port: 53317,
        protocol: ProtocolType::Https,
        download: true,
    }
}

/// Asserts that `value` has exactly the given field names (no extras, none
/// missing). Field order is not asserted (JSON object order is irrelevant).
fn assert_field_set(value: &Value, expected: &[&str], context: &str) {
    let obj = value.as_object().unwrap_or_else(|| {
        panic!("{context}: expected a JSON object, got {value}");
    });
    let mut actual: Vec<&str> = obj.keys().map(String::as_str).collect();
    let mut expected: Vec<&str> = expected.to_vec();
    actual.sort_unstable();
    expected.sort_unstable();
    assert_eq!(
        actual, expected,
        "{context}: wire field set diverged from upstream protocol v2 spec"
    );
}

// ---------------------------------------------------------------------------
// FileDto — protocol v2 section 2.1 (file metadata)
// ---------------------------------------------------------------------------

#[test]
fn file_dto_wire_fields_match_upstream_spec() {
    let dto = full_file_dto("file1");
    let json = serde_json::to_value(&dto).unwrap();

    assert_field_set(
        &json,
        &[
            "id", "fileName", "size", "fileType", "sha256", "preview", "metadata",
        ],
        "FileDto (all fields)",
    );
    assert_eq!(json["fileName"], "holiday photo.jpg");
    assert_eq!(json["fileType"], "image/jpeg");
    assert_eq!(json["size"], 1_048_576);
    assert_field_set(&json["metadata"], &["modified", "accessed"], "FileMetadata");
}

#[test]
fn file_dto_omits_absent_optional_fields() {
    // Upstream treats sha256/preview/metadata as optional; absent fields must
    // not be serialized as null.
    let dto = FileDto {
        id: "file1".to_string(),
        file_name: "a.bin".to_string(),
        size: 5,
        file_type: "application/octet-stream".to_string(),
        sha256: None,
        preview: None,
        metadata: None,
    };
    let json = serde_json::to_value(&dto).unwrap();

    assert_field_set(
        &json,
        &["id", "fileName", "size", "fileType"],
        "FileDto (optional fields absent)",
    );
}

// ---------------------------------------------------------------------------
// RegisterDtoV2 — protocol v2 section 2.2 (device info)
// ---------------------------------------------------------------------------

#[test]
fn register_dto_v2_wire_fields_match_upstream_spec() {
    let json = serde_json::to_value(full_register_dto()).unwrap();

    assert_field_set(
        &json,
        &[
            "alias",
            "version",
            "deviceModel",
            "deviceType",
            "fingerprint",
            "port",
            "protocol",
            "download",
        ],
        "RegisterDtoV2 (all fields)",
    );
    assert_eq!(
        json["deviceType"], "desktop",
        "deviceType must be lowercase on the wire"
    );
    assert_eq!(
        json["protocol"], "https",
        "protocol must be lowercase on the wire"
    );
    assert_eq!(json["port"], 53317);
    assert_eq!(json["download"], true);
}

// ---------------------------------------------------------------------------
// PrepareUpload — protocol v2 section 3.1 (POST /api/localsend/v2/prepare-upload)
// ---------------------------------------------------------------------------

#[test]
fn prepare_upload_request_golden_round_trip() {
    // Hand-written JSON in the exact upstream LocalSend wire format.
    let golden = json!({
        "info": {
            "alias": "Secret Banana",
            "version": "2.2",
            "deviceModel": "Windows",
            "deviceType": "desktop",
            "fingerprint": "random string",
            "port": 53317,
            "protocol": "https",
            "download": true
        },
        "files": {
            "file1": {
                "id": "file1",
                "fileName": "holiday photo.jpg",
                "size": 1048576,
                "fileType": "image/jpeg",
                "sha256": "deadbeef",
                "preview": "data:image/png;base64,iVBOR",
                "metadata": {
                    "modified": "2024-01-02T03:04:05.678Z",
                    "accessed": "2024-01-02T03:04:06.000Z"
                }
            },
            "file2": {
                "id": "file2",
                "fileName": "notes.txt",
                "size": 42,
                "fileType": "text/plain"
            }
        }
    });

    // Upstream payload must deserialize into the Rust model.
    let request: PrepareUploadRequestDtoV2 = serde_json::from_value(golden.clone()).unwrap();
    assert_eq!(request.info.alias, "Secret Banana");
    assert_eq!(request.info.version, "2.2");
    assert_eq!(request.info.device_type, Some(DeviceType::Desktop));
    assert_eq!(request.files.len(), 2);
    assert_eq!(request.files["file2"].file_name, "notes.txt");
    assert_eq!(request.files["file2"].sha256, None);

    // ...and re-serialize to the same field set (per object).
    let round_tripped = serde_json::to_value(&request).unwrap();
    assert_field_set(
        &round_tripped,
        &["info", "files"],
        "PrepareUploadRequestDtoV2",
    );
    assert_field_set(
        &round_tripped["info"],
        &[
            "alias",
            "version",
            "deviceModel",
            "deviceType",
            "fingerprint",
            "port",
            "protocol",
            "download",
        ],
        "PrepareUploadRequestDtoV2.info",
    );
    let files = round_tripped["files"].as_object().unwrap();
    assert_field_set(
        &files["file1"],
        &[
            "id", "fileName", "size", "fileType", "sha256", "preview", "metadata",
        ],
        "PrepareUploadRequestDtoV2.files[file1]",
    );
    assert_field_set(
        &files["file2"],
        &["id", "fileName", "size", "fileType"],
        "PrepareUploadRequestDtoV2.files[file2]",
    );

    // Semantically equal to the golden payload (field order irrelevant).
    assert_eq!(
        round_tripped, golden,
        "re-serialization diverged from the upstream wire format"
    );
}

#[test]
fn prepare_upload_response_golden_round_trip() {
    let golden = json!({
        "sessionId": "abc123",
        "files": {
            "file1": "token-1",
            "file2": "token-2"
        }
    });

    let response: PrepareUploadResponseDtoV2 = serde_json::from_value(golden.clone()).unwrap();
    assert_eq!(response.session_id, "abc123");
    assert_eq!(response.files["file1"], "token-1");

    let round_tripped = serde_json::to_value(&response).unwrap();
    assert_field_set(
        &round_tripped,
        &["sessionId", "files"],
        "PrepareUploadResponseDtoV2",
    );
    assert_eq!(round_tripped, golden);
}

// ---------------------------------------------------------------------------
// Info / PrepareDownload — protocol v2 sections 2.3 / 3.2
// ---------------------------------------------------------------------------

#[test]
fn info_response_dto_v2_wire_fields_match_upstream_spec() {
    let json = serde_json::to_value(InfoResponseDtoV2 {
        alias: "Secret Banana".to_string(),
        version: "2.2".to_string(),
        device_model: None,
        device_type: Some(DeviceType::Headless),
        fingerprint: "random string".to_string(),
        download: false,
    })
    .unwrap();

    assert_field_set(
        &json,
        &["alias", "version", "deviceType", "fingerprint", "download"],
        "InfoResponseDtoV2",
    );
    assert_eq!(json["deviceType"], "headless");
}

#[test]
fn prepare_download_response_golden_round_trip() {
    let golden = json!({
        "info": {
            "alias": "Secret Banana",
            "version": "2.2",
            "deviceModel": "Windows",
            "deviceType": "desktop",
            "fingerprint": "random string",
            "download": true
        },
        "sessionId": "session-42",
        "files": {
            "file1": {
                "id": "file1",
                "fileName": "holiday photo.jpg",
                "size": 1048576,
                "fileType": "image/jpeg"
            }
        }
    });

    let response: PrepareDownloadResponseDtoV2 = serde_json::from_value(golden.clone()).unwrap();
    assert_eq!(response.session_id, "session-42");
    assert_eq!(response.info.alias, "Secret Banana");
    assert_eq!(response.files["file1"].size, 1_048_576);

    let round_tripped = serde_json::to_value(&response).unwrap();
    assert_field_set(
        &round_tripped,
        &["info", "sessionId", "files"],
        "PrepareDownloadResponseDtoV2",
    );
    assert_eq!(round_tripped, golden);
}

// ---------------------------------------------------------------------------
// Multicast announcement — protocol v2 section 6 (UDP discovery)
// ---------------------------------------------------------------------------

#[test]
fn multicast_message_golden_round_trip() {
    let golden = json!({
        "alias": "Secret Banana",
        "version": "2.2",
        "deviceModel": "Windows",
        "deviceType": "desktop",
        "fingerprint": "random string",
        "port": 53317,
        "protocol": "https",
        "download": true
    });

    let message: MulticastMessageV2 = serde_json::from_value(golden.clone()).unwrap();
    assert_eq!(message.fingerprint, "random string");
    assert_eq!(message.port, 53317);

    let round_tripped = serde_json::to_value(&message).unwrap();
    assert_field_set(
        &round_tripped,
        &[
            "alias",
            "version",
            "deviceModel",
            "deviceType",
            "fingerprint",
            "port",
            "protocol",
            "download",
        ],
        "MulticastMessageV2",
    );
    assert_eq!(round_tripped, golden);
}

#[test]
fn multicast_message_unknown_device_type_falls_back_to_desktop() {
    // Protocol v2 section 7.1: unknown enum values must fall back to a
    // sensible default instead of failing the whole message.
    let json = json!({
        "alias": "Fridge Device",
        "version": "2.2",
        "deviceType": "fridge",
        "fingerprint": "random string",
        "port": 53317,
        "protocol": "http"
    });

    let message: MulticastMessageV2 = serde_json::from_value(json).unwrap();
    assert_eq!(message.device_type, Some(DeviceType::Desktop));
}

// ---------------------------------------------------------------------------
// Fingerprint handling — protocol v2 section 2.2 / 4 (device identity)
// ---------------------------------------------------------------------------

#[test]
fn fingerprint_is_preserved_verbatim_through_round_trip() {
    // Fingerprints are opaque strings (SHA-256 cert hash in HTTPS mode,
    // random string in HTTP mode). They must survive serialization byte for
    // byte — no trimming, casing, or encoding changes.
    let fingerprint = "A1b2C3d4E5f6+7/8==random string with spaces";
    let mut dto = full_register_dto();
    dto.fingerprint = fingerprint.to_string();

    let json = serde_json::to_value(&dto).unwrap();
    assert_eq!(json["fingerprint"], fingerprint);

    let parsed: RegisterDtoV2 = serde_json::from_value(json).unwrap();
    assert_eq!(parsed.fingerprint, fingerprint);
}

#[test]
fn register_dto_v2_accepts_missing_optional_fields() {
    // Older senders (protocol 2.0) omit deviceModel/deviceType/download.
    // The model must accept such payloads (defaults, not errors).
    let json = json!({
        "alias": "Old Sender",
        "version": "2.0",
        "fingerprint": "abc123",
        "port": 53317,
        "protocol": "http"
    });

    let dto: RegisterDtoV2 = serde_json::from_value(json).unwrap();
    assert_eq!(dto.alias, "Old Sender");
    assert_eq!(dto.device_model, None);
    assert_eq!(dto.device_type, None);
    assert!(!dto.download);
}

#[test]
fn protocol_version_constant_matches_v2() {
    assert_eq!(
        localsend::model::discovery::PROTOCOL_VERSION_V2,
        "2.2",
        "protocol version constant drifted; upstream compat is defined against 2.2"
    );
}

#[test]
fn file_dto_round_trip_is_lossless() {
    let dto = full_file_dto("file1");
    let json = serde_json::to_value(&dto).unwrap();
    let parsed: FileDto = serde_json::from_value(json).unwrap();
    assert_eq!(parsed.id, dto.id);
    assert_eq!(parsed.file_name, dto.file_name);
    assert_eq!(parsed.size, dto.size);
    assert_eq!(parsed.file_type, dto.file_type);
    assert_eq!(parsed.sha256, dto.sha256);
    assert_eq!(parsed.preview, dto.preview);
    assert_eq!(
        parsed.metadata.as_ref().unwrap().modified,
        dto.metadata.as_ref().unwrap().modified
    );
    assert_eq!(
        parsed.metadata.as_ref().unwrap().accessed,
        dto.metadata.as_ref().unwrap().accessed
    );
}

#[test]
fn prepare_upload_response_rejects_missing_session_id() {
    // sessionId is mandatory in the upstream spec; a payload without it must
    // not deserialize silently into an empty session.
    let json = json!({ "files": {} });
    assert!(serde_json::from_value::<PrepareUploadResponseDtoV2>(json).is_err());
}

// Silence unused-import warnings if HashMap ever becomes unnecessary here.
#[allow(dead_code)]
fn _assert_hashmap_used(_: &HashMap<String, String>) {}
