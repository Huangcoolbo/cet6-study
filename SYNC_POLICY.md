# CET-6 Sync Policy

This repository syncs selected CET-6 study content from `D:\Bo` into `D:\Ying`.

## Sync source -> target

- `D:\Bo\cet6-data\` -> `D:\Ying\data\`
- `D:\Bo\study-plan-week1.md` -> `D:\Ying\plans\study-plan-week1.md`

## Intentionally excluded

These are not synced because they are runtime/state-oriented, noisy, or not generally useful to publish:

- `data/index/dingtalk-state.json`
- OpenClaw runtime/config files such as `.openclaw/`, memory files, assistant persona files, tool notes, and similar workspace-specific artifacts

## Goal

Keep the GitHub repo focused on reusable CET-6 study materials that are worth learning from, while avoiding personal assistant state and machine-specific files.
