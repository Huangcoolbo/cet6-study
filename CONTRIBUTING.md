# Contributing Guide

这份文档面向会给这个仓库提交 PR 的人或账号。

目标很简单：
- 让贡献者知道什么能提
- 让审查者知道怎么判断
- 让仓库保持清楚、稳定、可持续维护

---

## 1. 先理解这个仓库是什么

这不是普通的笔记仓库。

它同时包含：
- CET-6 学习资料
- 学习计划与跟踪结构
- 部分项目运行状态
- 由 OpenClaw 参与维护的自动化与协作文档

所以提交 PR 时，不能只看“这个文件能不能跑”，还要看：
- 它是否真的属于 CET-6 项目
- 它是否会让项目更清楚
- 它是否会破坏同步、提醒或协作流程

---

## 2. 欢迎提交的内容

通常欢迎这些类型的 PR：

### 学习内容改进
- 补充高质量 CET-6 学习资料
- 整理答案与解析
- 增加听力原文、翻译材料、写作材料
- 改善 `data/input/` 中的结构化训练数据

### 结构与文档改进
- 改进 README、流程说明、目录说明
- 补充状态文件用途说明
- 修正文档中的模糊表达或不一致之处

### 项目流程改进
- 优化同步脚本
- 改进自动化边界说明
- 补充有必要的 PR 审查标准

---

## 3. 提 PR 前先检查这几件事

在提交前，请先问自己：

1. 这个改动是否明确服务于 CET-6 项目？
2. 这个文件是否适合出现在 GitHub 仓库里？
3. 如果它是状态文件，我是否写清楚了用途？
4. 如果它改动同步/自动化逻辑，我是否解释了为什么这样改？
5. 一个第一次进仓库的人能不能看懂我加的东西？

如果有一项答不上来，PR 往往还不够成熟。

---

## 4. 不要提交这些内容

默认不要提交：

- `.openclaw/`
- `AGENTS.md`
- `SOUL.md`
- `USER.md`
- `TOOLS.md`
- `IDENTITY.md`
- `HEARTBEAT.md`
- `memory/`
- 凭据、token、secret、账号信息
- 本机临时文件
- 与 CET-6 项目无关的实验性杂项

简单说：
**私人工作区文件不要提，项目边界之外的东西不要提。**

---

## 5. 关于状态文件的特殊说明

有些项目会把所有状态文件都排除，但这个仓库不是这样。

例如：
- `data/index/dingtalk-state.json`

这类文件虽然看起来像状态文件，但它们可能是项目提醒链路的一部分，因此**可以是合法 PR 内容**。

前提是：
- 它确实属于项目流程
- 不含敏感信息
- 文档里能解释清楚它的用途

如果你新增新的状态文件，请同时说明：
- 谁读它
- 谁写它
- 为什么它应该进入仓库

---

## 6. 对文档可读性的要求

这个仓库不是只给 OpenClaw 看，也要给人看。

所以贡献内容时请尽量做到：
- 命名清楚
- 目录放对位置
- 文档说人话
- 不依赖“默认大家都懂”

如果一个文件只有你自己或某个 agent 才能理解，那它大概率还需要补说明。

---

## 7. PR 描述建议模板

仓库已提供 `.github/PULL_REQUEST_TEMPLATE.md`。

建议在 PR 描述里至少写清楚：

### What
这次改了什么？

### Why
为什么要改？它解决了什么问题？

### Scope
改动范围在哪里？是否影响同步、提醒、状态文件或主流程？

### Notes
有没有额外注意事项？有没有不确定的地方？

另外，模板里额外加入了 **commit message 自查项**，目的是把 `COMMIT_MESSAGE_GUIDELINES.md` 的要求前移到提 PR 时，而不是等审查阶段才发现提交标题太空泛。

仓库现在还新增了 `.github/workflows/title-quality.yml`：
- PR 会检查标题是否符合 `<type>: <specific summary>`
- push 到仓库时会检查提交标题是否过于空泛

所以这些规范已经不只是“建议阅读”，而是进入了基础自动检查。

---

## 8. Commit message 也算贡献质量的一部分

提交标题请尽量具体，不要写成：
- `update`
- `fix`
- `sync`
- `misc cleanup`

更推荐：
- `docs: clarify sync responsibilities and repo boundaries`
- `fix: skip missing source paths in sync-cet6-study.ps1`
- `data: add CET-6 translation input examples`

详细规范见：`COMMIT_MESSAGE_GUIDELINES.md`

### 手动提交时的推荐做法

为了避免只有自动同步脚本能用更细的标题启发式，手动维护或巡检提交也建议复用仓库内置的推荐标题脚本：

```powershell
git add <你准备提交的文件>
./scripts/get-recommended-commit-title.ps1
git commit -m "<上一步输出的标题>"
```

如果想直接让脚本根据暂存区内容给出建议，可在 `git add` 之后运行：

```powershell
./scripts/get-recommended-commit-title.ps1
```

如果只是想先预览某批文件会得到什么标题，也可以显式传路径：

```powershell
./scripts/get-recommended-commit-title.ps1 -Paths Todo.md,WORKFLOW.md,scripts/audit-title-history.ps1
```

提交前如果不确定标题是否合规，再补一次：

```powershell
./scripts/validate-title.ps1 -Kind commit -Title "<拟使用的标题>"
```

这样做的目的不是让人机械照抄脚本，而是把已经在 `sync-cet6-study.ps1` 里验证过的细粒度标题启发式，也前移到日常手动提交流程里，减少再次回落到泛化 `chore:` / `sync:` 标题的概率。

## 9. 审查结果通常分四类

这个仓库的审查通常会落到以下四类：

- **Approve for merge**
- **Approve with notes**
- **Needs changes**
- **Do not merge**

如果你的 PR 被要求修改，通常不是因为“不能贡献”，而是因为它还没达到可以安全进入 `main` 的清晰度。

---

## 10. 最重要的一条

提交前请记住：

> **这个仓库应该同时让人和 OpenClaw 看得懂。**

能帮助 CET-6 学习、能保持项目清楚、能稳定协作的改动，才是好 PR。
