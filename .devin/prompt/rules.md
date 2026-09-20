# Rules for Quick Tasks (companion to `quick.md`)

These rules govern every task executed via `quick.md`. They exist so quick tasks ship fast **without** violating the quality standards of our full phase system (`phase.md`) or the agent system (`.devin/rules/35-agent-system.md`).

## 1. Scoping Rules

- **One task, one outcome.** A quick task must have a single, clearly defined deliverable. If the task expands into multiple features, stop and split it into separate quick tasks or escalate it to the phased plan (`phase.md`).
- **No scope creep.** Fix only what the task asks. If you discover adjacent problems, note them in the completion report — do not fix them silently.
- **Minimal upstream fixes.** Prefer fixing the root cause with the smallest possible change over downstream workarounds. No over-engineering: if a single-line change is sufficient, make a single-line change.
- **Respect existing architecture.** Quick tasks must not introduce new architectural patterns, new dependencies, or new modules. Work within the existing structure (MVVM, Hilt, Room, Compose conventions already in the codebase).

## 2. Before Editing

- **Read before write.** Always read the target file(s) and their callers/consumers before editing. Never edit from assumption.
- **Check for existing patterns.** Reuse existing utilities, components, design tokens, and ViewModels. Duplicating logic that already exists is a blocker.
- **Consult the docs — if they exist.** Read `docs/project.md`, `docs/toolset.md` (intent-map), `docs/CONCEPTS.md` (vocabulary), and `docs/plan.md` for past implementations, known constraints, current phase status, and which `.devin//` resources to invoke for your task type; check `docs/research.md` for prior tech decisions. These are per-project files: if absent, they will be created by the phase flow (phase.md §3–8) — don't block on them.
- **Check project permissions.** `.devin/config.json` defines what is pre-approved, what requires confirmation, and what is denied. Respect these rules — they are the project's safety boundary.

## 3. During Implementation

- **Follow code style.** Match the surrounding code exactly — naming, formatting, comment density (no new comments unless asked), and Kotlin/Compose idioms.
- **Design quality gate applies.** Even quick UI changes must follow the design gate in `phase.md` (§10): design tokens only (no hardcoded colors/spacing), Material 3, dark mode support, 48dp touch targets, and polished empty/loading/error states.
- **No weakened tests.** Never delete or weaken existing tests to make a change pass. Add a regression test for every bug fix when a test harness exists.
- **Conventional commits.** One logical change per commit, message format: `type(scope): description` (e.g., `fix(reader): handle empty article body`).
- **Use subagents by name.** Check `docs/toolset.md` intent-map to find which sub-agents are listed for your task type. Invoke subagents from `.devin/agents/` by their profile name (e.g., "review this using the code-reviewer subagent", "audit security using the security-auditor subagent"). If a task needs a sub-agent not in the intent map, update `docs/toolset.md` first (add it with rationale), then invoke. The 9 orchestrators in `.devin/orchestrators/` are reference docs — read them for guidance on which subagents to invoke, but invoke the subagents directly.
- **Use MCP tools where relevant.** Playwright MCP is available for browser-based testing and design cloning. GitHub MCP is available for issue/PR/repo operations. Use them instead of shell commands when they provide better integration.
- **Respect hook decisions.** Hooks (SessionStart, PreToolUse, PostToolUse, Stop) enforce policies automatically. If a hook blocks an action, do not attempt to bypass it — understand why it blocked and adjust your approach.

## 4. Verification Rules (tiered — remote-first)

Verification is mandatory; WHERE it runs is flexible. Use the cheapest tier that matches the change's blast radius — full gates belong on CI (`.github/workflows/checks.yml` runs ktlint + detekt + unit tests on every push/PR), not on the local machine.

- **Tier 1 — while iterating:** targeted compile only (e.g. `:app:compileUniversalNoMLDebugKotlin`), IDE feedback, scoped tests (`testDebugUnitTest --tests "*TouchedClass*"`). No full `assembleDebug`.
- **Tier 2 — before commit:** scoped lint/tests on touched code. Local Gradle build cache is ON — repeated runs are cheap.
- **Tier 3 — before merge/PR:** full gate via CI. Push the branch and let `checks.yml` run — a green remote check counts as verification; do not re-run locally for ceremony.
- **Full local build required** (`./gradlew assembleDebug`, pre-approved in `.devin/config.json`) only when: the change touches build files/dependencies/manifests/native code, an APK is needed on a device, or CI is unavailable and the user declines adding it.
- **Verify in context.** For UI changes, confirm the change renders correctly in both light and dark themes and does not regress adjacent screens.
- **Subagent verification.** Run the `code-reviewer` subagent (from `.devin/agents/`) on the diff before declaring the task complete. Quick tasks skip nothing except ceremony — Blockers and Criticals must still be resolved.
- **Stop hook checkpoint.** The Stop hook reminds you to confirm the correct verification tier was used (remote CI counts), code review done, and docs updated.

## 5. Documentation & Handoff Rules

- **Research before new tech.** Before adding any dependency, API, or unfamiliar pattern, consult `docs/research.md` (phase.md §7) — check prior decisions and record the new decision, alternatives considered, and rationale there.
- **Update `docs/project.md`** at the end of the task with what was implemented and any decisions made. **Append a session entry to `docs/tools-log.md`** listing every .devin resource invoked (skills, sub-agents, rules) — tool usage only, nothing else. Update `docs/toolset.md` intent-map if new tools became relevant or a new task type needs a row. Append any new technical findings, decisions, or gotchas to `docs/research.md`.
- **All new documentation goes in `docs/`** — never scatter `.md` files in the repo root or source folders.
- **Gitignore hygiene.** `.devin/` and `docs/*.md` (the knowledge layer) must always be gitignored (never pushed to GitHub). Repo-source docs like `docs/adr/` may stay tracked. `AGENTS.md` at the project root must NOT be gitignored — it is Devin's entry point and should be committed. Keep `.gitignore` minimal per phase.md §14 — only real artifacts, no dead entries.
- **Completion report.** End every quick task with a brief summary: what changed, files touched, verification results, and any noted follow-ups.

## 6. Escalation Rules

Escalate out of quick-task mode (into a planned phase) when:
- The change requires a database migration or schema change.
- The change touches more than ~5 files or crosses module boundaries.
- The change requires a new third-party dependency.
- The change alters public APIs, security behavior, or data handling.
- Verification cannot be completed in the current environment.
