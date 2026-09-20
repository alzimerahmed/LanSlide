# LanSlide — Competitive Analysis

## LocalSend (upstream)

- 92k stars; the de-facto FOSS AirDrop alternative. Strengths: protocol maturity (v2, TLS client certs), true cross-platform, no accounts/servers, active community.
- Weaknesses we can attack (Android-first): onboarding friction (pin/permission UX), transfer speed perception on large files, Android storage/SAF UX, background receive reliability under OEM battery killers.

## Alternatives

| App | Model | Notes |
|---|---|---|
| SHAREit / Xender | Proprietary, ad-laden, cloud-ish | Huge install base; privacy is the wedge |
| Nearby Share / Quick Share | Google, closed | Android-only reach; no desktop FOSS |
| KDE Connect | FOSS, cross-platform | Broader device-integration scope, heavier |
| Snapdrop / PairDrop | Web-based | Zero install but browser-tab fragility |

## LanSlide positioning

FOSS, offline, Android-first LocalSend fork. v1 = trustworthy rebrand with polished Android UX; post-v1 = Android-specific wins (SAF handling, background receive, quick-settings tile) while staying protocol-compatible with LocalSend peers (interop is a feature, not a bug — keep it).
