# LanSlide — Phased Plan

Lifecycle: Inception → Foundation → Build → Quality Gate → Anti-Vibe Audit → Ship.
Status columns: `pending` / `in_progress` / `done`. Update this file as tasks complete.

## Phase 1 — Inception (research, design, architecture)

| # | Task | Status |
|---|------|--------|
| 1.1 | Read upstream localsend repo docs (README, Wiki, protocol v2 spec) for reference — no code sync | done |
| 1.2 | Fork setup decision: repo location, upstream history dropped, independent line | done |
| 1.3 | ADR: applicationId — keep `org.localsend.localsend_app` vs rename to LanSlide identity | done |
| 1.4 | ADR: distribution — GitHub Releases only (Play Store question deferred) | done |
| 1.5 | Define v1 feature deltas vs upstream (Android-only scope, what to strip/ignore) | done |
| 1.6 | Branding direction: app name, icon, color scheme (LanSlide identity) | done |
| 1.7 | Architecture review of inherited stack (Flutter + Rust core, FRB, Refena) — confirm no structural changes for v1 | done |
| 1.8 | Competitive analysis / differentiation notes → docs/STRATEGY.md, docs/idea.md | done |

## Phase 2 — Foundation (docs + infrastructure)

| # | Task | Status |
|---|------|--------|
| 2.1 | Rewrite AGENTS.md for LanSlide (stack, gotchas, verification policy) | done |
| 2.2 | Create docs/plan.md (this file) | done |
| 2.3 | Create docs/toolset.md intent map (task type → skills/sub-agents/rules; web-only excluded) | done |
| 2.4 | Create docs/CONCEPTS.md project vocabulary | done |
| 2.5 | Create docs/tools-log.md resource log | done |
| 2.6 | Create docs/STRATEGY.md product strategy | done |
| 2.7 | Create docs/project.md, docs/research.md, docs/idea.md placeholders (Phase 1/3 fill-in) | done |
| 2.8 | CI plan: Android-only checks (fvm flutter analyze/test/format, cargo clippy/test --features full); strip/ignore non-Android targets from CI | pending |
| 2.9 | Verify .fvmrc pin + fvm toolchain usage documented for all agents | pending |

## Phase 3 — Build (fork setup, Android green, branding, protocol verification)

| # | Task | Status |
|---|------|--------|
| 3.1 | Fork localsend/localsend into LanSlide repo; drop upstream history | pending |
| 3.2 | Get `fvm flutter build apk` green on Android (debug first, then release) | pending |
| 3.3 | Codegen pipeline verified: build_runner, slang, FRB (`flutter_rust_bridge_codegen generate`) | pending |
| 3.4 | Rust core builds/tests with `--features full` (packages/core; keep server/cli compiling) | pending |
| 3.5 | LanSlide branding: app display name, launcher icon, theme colors | pending |
| 3.6 | applicationId decision applied per Phase 1 ADR (org.localsend.* vs LanSlide identity) | pending |
| 3.7 | Protocol v2 verification: device-to-device transfer between two Android devices (HTTP + UDP discovery + TLS client certs) | pending |
| 3.8 | Strip/ignore non-Android build targets from CI workflows (keep code compiling, not verified) | pending |
| 3.9 | FOSS compliance check: no GMS/proprietary deps in Android build | pending |

## Phase 4 — Quality Gate

| # | Task | Status |
|---|------|--------|
| 4.1 | Full CI gate green: `fvm flutter analyze`, `fvm flutter test`, `fvm dart format --set-exit-if-changed` (150 cols) | pending |
| 4.2 | Rust gate green: `cargo clippy --features full`, `cargo test --features full` | pending |
| 4.3 | Security audit of protocol/TLS/crypto surface (security-auditor) | pending |
| 4.4 | Code review of full fork diff (code-reviewer) | pending |
| 4.5 | Performance review of transfer pipeline (isolate layer, no main-isolate networking) | pending |

## Phase 4.5 — Anti-Vibe Audit

| # | Task | Status |
|---|------|--------|
| 4.5.1 | vibe-coding-auditor pass over codebase and docs — no AI slop, no dead code, no placeholder branding | pending |
| 4.5.2 | Fix all Blocker/Critical findings from audit | pending |

## Phase 5 — Ship

| # | Task | Status |
|---|------|--------|
| 5.1 | Signed release APK build via CI | pending |
| 5.2 | GitHub Release with APK + changelog | pending |
| 5.3 | README rebranded for LanSlide (FOSS, GitHub Releases only) | pending |
| 5.4 | Tag v1.0.0 | pending |
