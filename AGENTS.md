# LanSlide — Rules for AI Agents

## Project

LanSlide = fork of localsend/localsend (upstream: https://github.com/localsend/localsend). FOSS cross-platform file transfer over local network (protocol v2: HTTP + UDP multicast discovery, TLS with mandatory client certs, WebRTC via signaling server). Repo: https://github.com/alzimerahmed/LandSlide.git. Fully independent from upstream (no sync; upstream history dropped at fork). GitHub Releases ONLY.

**Scope:** Android-only for v1. Other platforms (iOS/Windows/macOS/Linux, CLI, server deployments) stay in the codebase but are NOT build/verify targets — do not spend effort keeping them green unless a change breaks the shared core.

**Stack (inherited from upstream — do not fight it):**
- Flutter app, version pinned in `.fvmrc` — use `fvm flutter` / `fvm dart`, never system toolchain. Bumping = update `.fvmrc` + CI + `app/pubspec.yaml` + flutter submodule (see CONTRIBUTING).
- Rust protocol core: 4 crates in one Cargo workspace (`packages/core` = `localsend` protocol/HTTP/multicast/crypto/WebRTC; `packages/localsend_isolates/rust` = FRB plugin crate; `server` = Axum WS signaling; `cli` = terminal client). Profiles live only in root `Cargo.toml`.
- Dart pub workspace: `app`, `packages/localsend_isolates`, `packages/typed_isolates` share one `pubspec.lock`.
- State: **Refena** (not Riverpod). Providers in `app/lib/provider/`; `ReduxProvider` + action classes for isolate-touching state. Bootstrap: `app/lib/config/init.dart` (`preInit`).
- Models: `dart_mappable` (`fromJson`/`toJson` = Map converters; `deserialize`/`serialize` = string ones). Freezed for FRB unions. Codegen: build_runner + slang (i18n).
- Dependency direction: `app` → `localsend_isolates` → (`typed_isolates`, `rust_lib_localsend_app` → `localsend` core). App depends ONLY on `localsend_isolates`.

**Key subsystems:**
- `app/` — Flutter UI, providers, persistence, platform channels.
- `packages/localsend_isolates/` — Dart isolate layer + FRB bindings; heavy networking never on main isolate. `lib/src/task/` = pure helpers only, isolate logic prohibited there.
- `packages/core/` — Rust protocol. Feature-gated (`crypto`, `http`, `multicast`, `webrtc`, `full`); **always build/test with `--features full`** (bare cargo check fails by design).
- `server/`, `cli/` — not v1 targets; keep compiling, don't extend.
- Identity: applicationId/namespace currently `org.localsend.localsend_app` — rename to LanSlide identity is a deliberate decision (ADR), do NOT rename casually.

**Build/verify (Android v1 targets):**
```bash
cd app
fvm flutter pub get
fvm dart run build_runner build        # dart_mappable, freezed, flutter_gen, mockito
fvm dart run slang                     # i18n codegen
fvm flutter build apk --debug          # or fvm flutter run
```
Checks (CI parity):
```bash
fvm dart format --set-exit-if-changed lib test   # 150 columns; generated code not format-checked
fvm flutter analyze
fvm flutter test
```
Rust (in `packages/core`): `cargo test --features full`, `cargo clippy --features full`. FRB codegen from `packages/localsend_isolates/`: `flutter_rust_bridge_codegen generate` (dart_format_line_length: 150).

**Gotchas:**
- Formatting is **150 columns** (`page_width: 150`, `trailing_commas: preserve`). Reformat generated Dart with `fvm dart format` after codegen; revert `app/test/mocks.mocks.dart` if codegen rewrites it at 80 columns.
- Only one upload session active at a time; cancellation via drop guards. No `auto_accept` in core — app answers `decision_tx`. Extend `ServerEventV2` rather than adding side channels.
- Server restarts when receive pin or web-send pin changes (pins fixed at start).
- Prefer `event.certFingerprint ?? event.info.fingerprint`.
- `PeerIp` includes IPv6 scope (`fe80::1%3`) — keep event ips dialable.
- Sync isolate state (`IsolateSyncServerStateAction`) BEFORE starting the server.

**Remote-first verification:** full gates on CI, not local. Local tiered: targeted `fvm flutter test <file>` / `fvm flutter analyze` while iterating → scoped checks before commit → CI before merge. **Never run `fvm flutter build apk` locally while iterating** — the APK build is verified by CI (`build_android_apk.yml`) after push. Full local builds only if an APK must be installed on a device or the build system itself is being debugged.

**IMPORTANT — small-batch local builds (mandatory):** Flutter+Rust toolchain is heavy. When local builds needed:
- One task per invocation; scoped tests (`fvm flutter test test/unit/util/foo_test.dart`) > whole-suite runs while iterating.
- Let pub workspace + cargo target dir caches work; don't re-run green tasks.
- Long build → background + poll, keep machine responsive.

## Entry Point

Auto-loaded by Devin every session. Entry to prompt system in `.devin/prompt/`. Read `.devin/prompt/map.md` before any task — system map.

## Resource Discipline (mandatory, non-trivial tasks)

Before any non-trivial task:
1. Read `docs/toolset.md` intent-map (task type → resources)
2. Invoke every skill + sub-agent in that row
3. Read every rule for that task type (`.devin/rules/`)
4. At task end: `code-reviewer` sub-agent on final diff (non-negotiable)
5. Append learnings via `/ce-compound` if durable lesson

**Background sub-agents:** run sub-agents background (`is_background=true`) when result not immediately needed; keep working while they run. Launch independent sub-agents parallel, continue local work; notified on completion. Block only when sub-agent output = hard dependency for next step.

Phase implementations (task completes a docs/plan.md row): /ce-work mandatory.

Skip all this for single-line edits, pure Q&A, reading files.

## Project-Type Filter (native app, Flutter+Rust)

Not a website. Per `docs/toolset.md` intent-map:
- **Skip web-only:** frontend-designer, css-architect, pwa-engineer, seo-specialist, search-optimization, playwright-design-clone.
- **Keep universal:** code-reviewer, debugger, test-engineer, security-auditor (protocol/TLS/crypto surface is security-critical), performance-engineer, git-master, migration-specialist, docs-writer, i18n-specialist (slang; upstream ships many locales), build-optimizer, caveman-compressor, pixel-analyst, vibe-coding-auditor, type-safety-engineer (Dart/Rust), database-engineer (persistence where used), state-manager (Refena patterns).
- **Quality gates:** `fvm flutter analyze`, `fvm flutter test`, `fvm dart format --set-exit-if-changed`, `cargo clippy/test --features full` — no browser tooling. Respect FOSS: no GMS/proprietary deps.
- **Transfer pipeline:** features share `packages/core` protocol + isolate layer — check core before per-feature logic. Networking changes need Rust-side tests.

## Communication Style

Default **caveman-lite** (lightly compressed, readable, technically accurate). `/caveman` skill for full/ultra/wenyan modes.

## Quick Task Flow

Quick tasks: `.devin/prompt/quick.md` (commandments) + `.devin/prompt/rules.md` (scoping, verification, escalation). Phased work: `.devin/prompt/phase.md`.

## Key References

- `docs/toolset.md` — intent map (task type → skills, sub-agents, rules)
- `docs/plan.md` — phased plan + status
- `docs/project.md` — project state/structure
- `docs/tools-log.md` — .devin resources invoked per session
- `docs/CONCEPTS.md` — project vocabulary (transfer-pipeline terms)
- `docs/research.md` — research, ADRs, gotchas
- `docs/idea.md` — competitive analysis
- Upstream repo — README/Wiki/docs for protocol & feature reference (no code sync)
