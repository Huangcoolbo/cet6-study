# PR Merge Policy

This document defines how pull requests should be reviewed before merging into `main` for the CET-6 study repository.

## Role split

- The assistant acts as CI/CD steward and reviewer.
- The repository owner remains the final authority unless explicit auto-merge authorization is granted.

## Default rule

PRs should be merged into `main` only when they are clearly within project scope, structurally safe, and do not introduce private, runtime, or machine-specific content.

## Allowed change types

These are normally acceptable if quality is good:

- CET-6 study materials under `data/`
- Study plans under `plans/`
- Repository documentation such as `README.md`, `SYNC_POLICY.md`, and this policy file
- Sync automation files that support the approved CET-6 sync workflow in `D:\Ying`

## Changes that require extra caution

These should be reviewed more strictly:

- Changes to sync scripts
- Changes to `.gitignore`
- Changes affecting push behavior, automation cadence, or branch workflow
- Bulk deletions or major file moves
- Rewrites of existing study materials

## Changes that should normally be rejected

Do not merge these into `main` unless the owner explicitly approves:

- OpenClaw runtime files such as `.openclaw/`
- Persona, memory, or workspace-private files such as `AGENTS.md`, `SOUL.md`, `USER.md`, `TOOLS.md`, `IDENTITY.md`, `HEARTBEAT.md`, or `memory/`
- Machine-specific state files such as `data/index/dingtalk-state.json`
- Secrets, tokens, credentials, personal identifiers, or hidden config not meant for publication
- Off-topic files unrelated to CET-6 learning or the approved repo automation

## Review checklist

Before recommending merge, check:

1. **Scope** — Is the PR clearly about CET-6 content or approved repo automation?
2. **Safety** — Does it avoid private/runtime/sensitive files?
3. **Structure** — Does it fit the repo layout cleanly?
4. **Quality** — Is the content accurate, readable, and useful?
5. **Automation compatibility** — Will it break sync or create noisy commit churn?
6. **Main branch impact** — Is it safe to land directly on `main`?

## Decision labels

The assistant should classify each PR using one of these outcomes:

- **Approve for merge** — Safe and in scope
- **Approve with notes** — Safe, but with minor concerns or follow-ups
- **Needs changes** — Useful direction, but not ready for `main`
- **Do not merge** — Unsafe, out of scope, or privacy/risk issue

## Auto-merge boundary

Unless the owner explicitly expands authority, the assistant may review and recommend, but not assume permanent authority to merge all external PRs automatically.

## Practical interpretation

If a PR helps the CET-6 repo become a better study project without leaking private workspace content or destabilizing automation, it is usually a candidate for merge.
