# LanSlide — Product Strategy

**What:** LanSlide is a fork of LocalSend (localsend/localsend, ~92k stars) — FOSS, cross-platform file transfer over the local network using protocol v2 (HTTP + UDP multicast discovery, mutual TLS with client certificates). No cloud, no accounts, no tracking.

**v1 scope:** Android-only. Other platforms remain in the codebase but are not build/verify targets. Distribution: GitHub Releases only (FOSS, no Play Store dependency assumed).

**Positioning:** Ship a working, branded Android fork fast by inheriting the mature upstream stack (Flutter + Rust core) rather than rebuilding. Value is in curation and identity, not protocol reinvention.

**Open questions to resolve in Phase 1 (ADRs):**
- **Branding:** app name, launcher icon, color scheme — full LanSlide identity vs. subtle rebrand of LocalSend.
- **applicationId:** keep `org.localsend.localsend_app` (avoids breaking existing installs/plugins) vs. rename to a LanSlide package identity. Deliberate ADR, not a casual rename.
- **Distribution:** GitHub Releases only for v1, or add Play Store / F-Droid later? Play Store implies signing, privacy policy, and review overhead.
- **Feature deltas:** what to strip or defer for Android-only v1 (desktop/CLI/server targets stay compile-only), and which upstream features are must-have vs. cut.

**Non-goals for v1:** iOS, desktop, CLI, server deployments, upstream sync, WebRTC signaling server work beyond keeping it compiling.
