# LanSlide — Project

FOSS Android file-transfer app. Fork of LocalSend (https://github.com/localsend/localsend) — nearby-device file sharing over local network, no internet required, no tracking.

## Status

- Phase 1 (Inception): done — this doc + docs/research.md + docs/idea.md
- Phase 2 (Foundation): done — docs/plan.md, docs/toolset.md, docs/CONCEPTS.md, docs/tools-log.md, docs/STRATEGY.md
- Phase 3 (Build): pending — fork codebase not yet imported into this workspace

## Structure (once fork is imported)

Upstream monorepo layout (see AGENTS.md for full detail):

| Path | What |
|---|---|
| `app/` | Flutter app (UI, providers, persistence, platform channels) |
| `packages/core/` | Rust protocol crate (`localsend`) |
| `packages/localsend_isolates/` | Dart isolate layer + FRB bindings + plugin crate |
| `packages/typed_isolates/` | Typed Dart isolate wrapper |
| `server/`, `cli/` | Not v1 targets; keep compiling |
| `support/scripts/` | Release/packaging scripts |

## v1 scope

- Android APK builds (debug + signed release via GitHub Releases)
- Core transfer: send/receive files, multicast discovery, pin verification
- LanSlide branding (name, icon, theme)
- Android-only CI

## Out of scope v1

- iOS/desktop/CLI feature work, WebRTC signaling server deployment, Play Store/F-Droid distribution
