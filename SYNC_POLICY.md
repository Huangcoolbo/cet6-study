# CET-6 Sync Policy

This repository syncs selected CET-6 project content from `D:\Bo` into `D:\Ying`, and then pushes the result to GitHub.

## Sync source -> target

- `D:\Bo\cet6-data\` -> `D:\Ying\data\`
- `D:\Bo\study-plan-week1.md` -> `D:\Ying\plans\study-plan-week1.md`

## Included content

The sync is intended to preserve project content that is useful for CET-6 study and project execution, including:

- learning materials
- study plans
- indexes and task boards
- structured training input
- project execution state that belongs to the CET-6 workflow

## Important clarification: DingTalk state is in scope

`data/index/dingtalk-state.json` is part of the project and should be synced.

Reason:
- it belongs to the DingTalk reminder workflow
- that workflow is executed by another OpenClaw instance
- the file acts as shared project state, not meaningless local noise

So it should be treated as project data, even though it is state-like.

## Intentionally excluded

These are still excluded because they are workspace-private or unrelated to the published CET-6 repo:

- OpenClaw runtime/config files such as `.openclaw/`
- memory files
- assistant persona files
- local tool notes
- other machine-specific artifacts not directly part of the CET-6 project

Examples:
- `AGENTS.md`
- `SOUL.md`
- `USER.md`
- `TOOLS.md`
- `IDENTITY.md`
- `HEARTBEAT.md`
- `memory/`

## Goal

Keep the GitHub repo focused on reusable CET-6 study materials and project-operational files that matter, while avoiding private workspace content that does not belong in the repository.
