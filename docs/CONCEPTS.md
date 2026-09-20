# LanSlide — Concepts (Project Vocabulary)

- **protocol v2** — LocalSend's current transfer protocol: HTTP-based, TLS-secured, with UDP multicast discovery.
- **HTTP server/client (Rust)** — protocol implementation in `packages/core` (`localsend` crate); device acts as both sender (client) and receiver (server).
- **UDP multicast discovery** — devices announce themselves on the LAN via multicast so peers appear without manual entry.
- **TLS with mandatory client certificates** — every connection requires mutual TLS; both sides present certificates.
- **fingerprint** — SHA-256 hash of the peer's client certificate DER; used as stable peer identity. Prefer `event.certFingerprint ?? event.info.fingerprint`.
- **ServerEventV2** — enum of server-side protocol events; extend this rather than adding side channels.
- **decision_tx** — channel the app uses to answer incoming transfer requests; core has no `auto_accept`, the app decides.
- **drop guards (PendingSessionGuard / UploadGuard)** — RAII-style Rust guards ensuring session cleanup/cancellation; only one upload session active at a time.
- **FRB (flutter_rust_bridge)** — codegen bridging Dart and Rust; generates `rust_lib_localsend_app` bindings from `packages/localsend_isolates/rust`.
- **isolates (parent/child)** — Dart concurrency model; heavy networking runs off the main isolate via the `localsend_isolates` package (parent/child isolate pairs).
- **Refena** — state management library (not Riverpod). `NotifierProvider` for simple state, `ReduxProvider` + action classes for isolate-touching state.
- **dart_mappable** — model serialization codegen; `fromJson`/`toJson` (Map) and `deserialize`/`serialize` (string) converters.
- **slang** — i18n codegen for Flutter; `fvm dart run slang` generates translation code.
- **web send** — browser-based send/receive feature served by the device's HTTP server; has its own pin.
- **pin** — numeric code required to accept a transfer (receive pin and web-send pin are fixed at server start; changing them restarts the server).
- **PeerIp / IPv6 scope** — peer address type that may include an IPv6 zone identifier (`fe80::1%3`); keep event IPs dialable.
- **FOSS flavor** — build variant guaranteeing no Google Mobile Services / proprietary dependencies.
