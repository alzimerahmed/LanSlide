# LanSlide — Toolset Intent Map

Task type → applicable skills / sub-agents / rules from the `.devin/` system.
Project type: native Flutter + Rust app (Android-only v1). Not a website.

## Applicable

| Task type | Skills | Sub-agents | Rules |
|-----------|--------|------------|-------|
| Docs / vocabulary / ADRs | documentation | docs-writer | 31-documentation |
| Git workflow, fork setup, history | git-workflow-version-control | git-master | 26-git-workflow |
| Build system, CI, APK pipeline | build-tools-bundlers | build-optimizer | 27-build-tools |
| Monorepo (Dart pub workspace + Cargo workspace) | monorepo-management | monorepo-manager | 32-monorepo |
| Code review before merge | code-review | code-reviewer | 05-code-review |
| Bug fixing | bug-fix-debugging | debugger | 06-debug |
| Testing setup, test architecture | testing-qa | test-engineer | 07-testing |
| Security (TLS, client certs, protocol surface) | security-audit | security-auditor | 09-security |
| Performance (transfer pipeline, isolates) | performance-optimization | performance-engineer | 10-performance |
| Refactoring / upstream divergence | migration-refactoring | migration-specialist | 17-migration |
| State (Refena providers, ReduxProvider actions) | state-management-data-fetching | state-manager | 20-state-management |
| File handling / transfer features | file-handling-media-uploads | file-handler | 23-file-handling |
| i18n (slang, upstream locales) | i18n-localization | i18n-specialist | 15-i18n |
| Type safety (Dart + Rust) | type-safety-typescript | type-safety-engineer | 28-type-safety |
| Persistence (where used) | database-design-optimization | database-engineer | 16-database |
| DX / agent ergonomics | developer-experience | dx-optimizer | 30-dx |
| Icon / visual asset analysis | pixel-perfect-image-analysis | pixel-analyst | 39-pixel-perfect-image-analysis |
| Anti-slop audit | anti-vibe-coding | vibe-coding-auditor | 36-anti-vibe-coding |
| Token-efficient comms (on request) | caveman-compression | caveman-compressor | 37-caveman |
| Orchestration (all phases) | — | — | 35-agent-system |

## Excluded (web-only — native Flutter app)

| Sub-agent | Reason |
|-----------|--------|
| frontend-designer | Web UI design; Flutter has its own widget/theming system |
| css-architect | No CSS in Flutter |
| pwa-engineer | Not a web app |
| seo-specialist | No public web pages |
| search-optimization | Same as above |
| playwright-design-clone | Browser-based UI cloning; not applicable |

## Quality Gates (Flutter + Rust)

```bash
# Dart/Flutter (from app/)
fvm flutter analyze
fvm flutter test
fvm dart format --set-exit-if-changed lib test   # 150 columns

# Rust (from packages/core/)
cargo clippy --features full
cargo test --features full

# FRB codegen (from packages/localsend_isolates/)
flutter_rust_bridge_codegen generate             # dart_format_line_length: 150
```

No browser tooling. Respect FOSS: no GMS/proprietary dependencies.
