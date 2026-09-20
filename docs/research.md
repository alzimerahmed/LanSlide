# LanSlide — Research

## Upstream: LocalSend (localsend/localsend)

- ~92k stars, 5.1k forks, 2.1k commits. FOSS (Apache-2.0/GPL-3.0 mix per file headers). Cross-platform (Android, iOS, Windows, macOS, Linux) + CLI + WebRTC signaling server.
- **Stack:** Flutter (version pinned via `.fvmrc`, fvm-managed) + Rust core. Dart pub workspace (app, localsend_isolates, typed_isolates) + Cargo workspace (core, FRB plugin crate, server, cli).
- **Protocol v2:** HTTP server implemented in Rust (`packages/core`), UDP multicast discovery (v2.2, v1 messages not parsed), TLS with per-device on-the-fly certs and **mandatory client certificates** (optional only for web-send browser pages). Peer identity = uppercase-hex SHA-256 of client cert DER. Web send = browser download page with pin, assets embedded from `packages/core/assets/web/`.
- **Concurrency model:** heavy networking off main isolate. Parent isolate holds one `IsolateConnector` per child (http scan, multicast, http upload, http server) + `SyncState` mirrored to children. Only one upload session active at a time; cancellation via drop guards. No `auto_accept` in core — app answers `decision_tx` oneshot.
- **State:** Refena (not Riverpod). `ReduxProvider` + action classes for isolate-touching state. Bootstrap in `app/lib/config/init.dart`.
- **Models:** dart_mappable (Map vs string converters renamed), freezed for FRB unions. i18n via slang, many locales shipped upstream.
- **Upstream policy note:** LocalSend disallows most AI-generated contributions — irrelevant for us (independent fork, no upstream PRs planned).

## LanSlide fork decisions

- **Fork model:** same as SnapForge/ImageToolbox — clone upstream, drop history, independent line. No code sync with upstream.
- **v1 scope: Android only.** Other platform targets stay in tree but are not build/verify targets. CI reduced to Android paths.
- **Distribution:** GitHub Releases only (matches AGENTS.md; upstream also ships Play Store/F-Droid — not ours unless decided later).

## ADRs

### ADR-001: Android-only v1
Keep all platform code; CI and verification target Android (`fvm flutter build apk`). Rationale: smallest verification surface while forking; desktop targets re-enable later without structural work since upstream keeps them working.

### ADR-002: Application identity (OPEN — decide in Phase 3)
applicationId/namespace currently `org.localsend.localsend_app`. Options: (a) keep as-is through v1, (b) rename to `com.alzimerahmed.lanslide`. Renaming touches Android manifest, method-channel name (`org.localsend.localsend_app/localsend`), deep links, and Rust-side references. Decision needed before first release; do NOT rename casually.

### ADR-003: Fork delta (OPEN)
What actually changes vs upstream in v1: branding (name, icon, colors), README, CI (Android-only workflows), release pipeline. Feature deltas deferred to post-v1.

## Gotchas (inherited from upstream AGENTS.md)

- Bare `cargo check` on `packages/core` fails — modules unconditional, deps optional. Always `--features full`.
- Formatting 150 columns; codegen rewrites mocks at 80 — revert `app/test/mocks.mocks.dart` if it appears.
- Server restart required when receive pin or web-send pin changes (fixed at start).
- Sync isolate state BEFORE starting server (children read `syncState` at start).
- `PeerIp` carries IPv6 scope (`fe80::1%3`); keep event ips dialable.
- Prefer `event.certFingerprint ?? event.info.fingerprint`.
