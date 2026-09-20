# LanSlide — FOSS file transfer over your local network

<div align="center">

*Send files and messages to nearby devices directly over the LAN — no internet, no servers, no accounts.*

[Download](#download) • [Features](#features) • [How It Works](#how-it-works) • [Building](#building)

</div>

---

## About

LanSlide is a free, open-source app for securely sharing files and messages with nearby devices over the local network. It is an independent fork of [LocalSend](https://github.com/localsend/localsend) — upstream history was dropped at the fork point and the project is developed on its own line.

Transfers use the LocalSend Protocol v2: HTTPS with on-the-fly TLS certificates and mandatory client certificates, plus UDP multicast discovery. No external servers are involved, so the app works fully offline. LanSlide remains wire-compatible with LocalSend, so the two apps can transfer to each other on the same network.

v1 targets **Android only**. Other platforms remain in the codebase but are not build or release targets.

## Features

- Direct device-to-device transfer over Wi-Fi/LAN — no internet connection required
- Protocol v2: TLS with mandatory client certificates, UDP multicast discovery
- Interoperable with LocalSend clients on the same network
- Quick Settings tile to toggle receive mode
- Trusted devices: fingerprint allowlist with per-device always-accept
- Transfer history with resend
- Rememberable save location with MediaStore direct-write for media
- Onboarding with contextual permission rationale (location permission is required for multicast discovery)
- Foreground-service receive mode with battery-optimization guidance for OEM battery killers
- Web send page with drag-and-drop

## Download

LanSlide is distributed exclusively through GitHub Releases. APKs are built and signed by CI.

1. Go to the [Releases page](https://github.com/alzimerahmed/LandSlide/releases)
2. Download the APK matching your device ABI (`arm64-v8a` for most modern phones)
3. Install the APK (enable "Install unknown apps" for your browser/file manager if prompted)

Requires Android 5.0 or newer.

## How It Works

Devices discover each other via UDP multicast on port 53317 and communicate over a REST API secured with HTTPS. Each device generates its TLS certificate on the fly and requires client certificates from peers, so both ends are authenticated. The protocol specification is documented in the [localsend/protocol](https://github.com/localsend/protocol) repository.

Firewall note: if transfers fail, allow incoming TCP/UDP on port 53317 and disable AP isolation on your router.

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter (Dart) |
| State | Refena |
| Protocol core | Rust (Axum HTTP, multicast, crypto, WebRTC) |
| Bridge | flutter_rust_bridge, Dart isolates |
| Models | dart_mappable, Freezed |
| i18n | slang |

## Project Structure

```text
app/                        Flutter UI, providers, persistence, platform channels
packages/core/              Rust protocol core (localsend crate)
packages/localsend_isolates/  Dart isolate layer + FRB bindings
packages/typed_isolates/    Typed isolate helpers
server/                     Axum WebSocket signaling server (not a v1 target)
cli/                        Terminal client (not a v1 target)
```

## Building

Requirements: Flutter (version pinned in [.fvmrc](.fvmrc) — use [fvm](https://fvm.app)), Rust, JDK 17.

```bash
cd app
fvm flutter pub get
fvm dart run build_runner build
fvm dart run slang
fvm flutter run
```

Release APK:

```bash
cd app
fvm flutter build apk --release --split-per-abi
```

<details>
<summary>Checks (CI parity)</summary>

```bash
fvm dart format --set-exit-if-changed lib test   # 150 columns
fvm flutter analyze
fvm flutter test
```

Rust core (in `packages/core`):

```bash
cargo test --features full
cargo clippy --features full
```

</details>

<details>
<summary>Release signing</summary>

Release builds are signed in CI with secrets stored in the repository settings (`ANDROID_KEY_PROPERTIES`, `ANDROID_KEY_STORE`, both base64-encoded). The keystore is never committed.

</details>

## Contributing

Fork the repository, create a branch, and open a pull request. Bug fixes can go straight to a PR; larger changes should start with an issue describing the problem and proposed approach. Translations live in `app/assets/i18n/`.

## License

This project is licensed under the [Apache-2.0 license](LICENSE).

Fork of [LocalSend](https://github.com/localsend/localsend) by the LocalSend contributors — maintained by Alzimer Ahmed.
