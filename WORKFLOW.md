# CET-6 Project Workflow

这份文档解释这个仓库是怎么运转的。

它面向两类读者：
- **人类协作者**：想快速理解这个项目是怎么工作的
- **OpenClaw / 自动化执行者**：需要稳定地读取、更新、同步项目内容

---

## 1. 项目目标

这个项目的目标不是单纯存笔记，而是把 CET-6 备考过程变成一个可维护、可协作、可持续推进的系统。

系统里包含三类东西：
- **学习资料**：真题、答案、听力原文、写作与翻译材料、词句输入
- **执行结构**：学习计划、索引、任务板、跟踪项
- **运行状态**：提醒状态、协作状态、自动化同步结果

---

## 2. 关键目录在流程中的角色

### `plans/`
用于保存学习计划，例如按周安排的任务。

### `data/`
项目核心数据区。

#### `data/index/`
保存索引、任务板、跟踪器，以及部分运行状态。

#### `data/input/`
保存结构化训练输入，便于后续训练、提取、复习或提醒流程消费。

#### 其他目录
- `answers/`：答案和解析
- `papers/`：试卷与真题
- `reviews/`：复盘
- `sources/`：来源评估
- `transcripts/`：听力原文
- `translation/`：翻译训练
- `writing/`：写作训练

---

## 3. 当前参与角色

### 角色 A：当前这个 OpenClaw
负责：
- 把 `D:\Bo` 中与 CET-6 项目有关的内容同步到 `D:\Ying`
- 维护 `D:\Ying` 仓库结构
- 自动提交并 push 到 GitHub
- 维护文档可读性
- 审查 PR，判断是否适合合并到 `main`
- 充当该仓库的 CI/CD steward

### 角色 B：另一个 OpenClaw
负责：
- 执行项目中的部分提醒链路
- 当前已知包括 **钉钉提醒相关流程**

### 角色 C：人类维护者 / 仓库所有者
负责：
- 给出最终方向
- 决定是否扩大自动化权限
- 对高风险修改、main 分支合并保留最终决定权

---

## 4. 当前主流程

当前主流程可以理解为：

1. 上游内容在 `D:\Bo` 中被整理或更新
2. 当前 OpenClaw 定时读取 `D:\Bo`
3. 将允许同步的内容复制到 `D:\Ying`
4. 在 `D:\Ying` 中进行版本管理
5. 通过 `sync-cet6-study.ps1` 作为主入口执行自动提交并 push 到 GitHub 仓库（提交标题应保持描述性且不带时间戳）
6. 人类或其他 OpenClaw 可以基于这个仓库继续消费、提醒、审查或扩展

简化表示：

`D:\Bo` -> `D:\Ying` -> `GitHub(main)`

其中：
- `D:\Bo` 是只读上游来源之一
- `D:\Ying` 是当前项目仓库工作区
- GitHub 是共享、审查、备份与协作中心

当前推荐把 `sync-cet6-study.ps1` 视为唯一主同步入口。
`auto-push.ps1` 可以保留为兼容层，但不建议继续与主脚本并行扩展职责，否则会让同步边界、提交范围和维护责任重新变得模糊。

当前已核对本机两个已知自动入口：
- `CET6StudyAutoPush` 计划任务当前应优先直接执行 `D:\Ying\sync-cet6-study.ps1`
- `CET6StudyResumeCatchup` 计划任务当前执行 `D:\Ying\resume-catchup.ps1`
- `resume-catchup.ps1` 内部再调用 `D:\Ying\sync-cet6-study.ps1`
- 如果 `CET6StudyAutoPush` 仍暂时指向 `D:\Ying\auto-push.ps1`，可视为兼容回退状态，但应尽快收敛回主入口

仓库已补充几个本机辅助脚本：
- `scripts/audit-sync-entrypoints.ps1`：重复检查这些本地入口是否仍指向 `D:\Ying` 下的现行脚本，并区分“首选主入口”与“兼容回退入口”
- `scripts/set-autopush-task-entrypoint.ps1`：把 `CET6StudyAutoPush` 的计划任务动作收敛为直接调用 `D:\Ying\sync-cet6-study.ps1`
- `scripts/audit-title-history.ps1`：批量回放最近一段 git 历史并按当前 `validate-title.ps1` 规则标记 PASS / FAIL，支持聚合失败原因摘要（必要时可用 `-FailuresOnly` 只看失败项）、`-SummaryOnly` 只输出统计摘要，以及 `-AsJson` / `-AsMarkdown` 输出结构化结果与人类可读摘要；若要给 workflow run summary、巡检播报或聊天汇报使用更短版本，还可配合 `-Compact` 仅输出统计与失败原因聚合，不展开逐条标题明细，方便在“观察标题校验是否误报/漏报”时快速区分“历史遗留坏标题”与“当前规则可能错杀的正常标题”；当前 JSON / Markdown 摘要会额外给出 `AuditScope`（本次审计到底覆盖 `latest N commits` 还是某个 `revision range`）、`Outcome`（`clean` / `legacy-only` / `needs-review`）、`SuggestedAction`（下一步是否需要继续追查的提示）、`NeedsReview` / `FailureBucketCount`，以及本次范围内 `NewestCommit` / `OldestCommit` 的 SHA + 标题边界，减少后续还得先下载完整明细或手动翻 log 才能判断“这份 artifact 到底对应哪段历史”；当前 `title-quality` 工作流已在 push 校验后额外导出对应范围的 JSON、紧凑 Markdown 摘要与完整 Markdown 明细为 `title-audit-summary` artifact，并把紧凑摘要直接附到 workflow run summary，减少后续人工下载后再二次整理。最新一次结合真实历史的本地抽查中，紧凑摘要会明确输出 `Outcome: legacy-only`，用于表示“命中的失败全部仍属已知历史坏标题桶”，从而把它与完全无失败的 `clean` 以及需要继续追查规则/样本的 `needs-review` 区分开；现在摘要里还会同步给出 `NeedsReview` 布尔值、`FailureBucketCount`、`RepeatedTitleCount`、`PassOnlyRepeatedTitleCount`、`TopRepeatedTitleCount` / `TopRepeatedTitle` / `TopRepeatedTitleStatusMix`、`NeedsNamingReview` 与首尾 commit 边界，方便后续巡检脚本或人工在不翻完整明细的情况下，先快速判断“要不要追”“失败主要分成了几类”“这次看的是哪一段历史”，以及“虽然都过检了，但当前最严重的重复标题热点到底是哪一条、它重复了几次、涉及 PASS 还是 FAIL”；其中 `NeedsNamingReview=true` 专门用来提示“校验虽然全绿，但重复标题已经重到值得继续细化命名规则”，避免把“没有失败”和“artifact 信息量已经足够”误当成一回事，减少还得继续展开完整重复标题列表才能判断是否值得进一步细化命名规则。为减少这种“技术上合规、但 artifact 信息量偏低”的重复标题，标题生成启发式现已抽到 `scripts/get-recommended-commit-title.ps1` 里统一维护，`sync-cet6-study.ps1` 直接复用它；现在也把它明确列为手动维护 / 巡检提交的推荐入口：先 `git add` 目标文件，再运行 `./scripts/get-recommended-commit-title.ps1` 基于暂存区生成建议标题，必要时再用 `./scripts/validate-title.ps1 -Kind commit -Title ...` 做提交前自检。这样后续就不必为“自动同步”和“人工维护”分别维护两份标题规则。当前这套启发式除了已有的按区域汇总（如 `index data`、`training inputs`、`study plans`、`project docs`、`automation`）外，还会对最近真实历史里高频重复的组合给更贴近语义的标题候选：例如 `data/index/` 下共享状态 + 少量配套文档会优先落成 `data: refresh DingTalk reminder state and supporting docs` 或 `docs: clarify index data guidance and shared state files`；`Todo.md + WORKFLOW.md + dingtalk-state.json` 这类巡检型组合，则优先改写为 `review: track DingTalk state follow-up and workflow notes`；如果同一批 DingTalk 状态 / workflow 文档 / 自动化脚本一起被调整，则进一步优先落成 `fix: refine DingTalk state workflow automation and docs`。而当这类脚本又恰好只是在收紧标题审计 / 标题生成规则（例如只碰到 `scripts/audit-title-history.ps1`、`scripts/get-recommended-commit-title.ps1`、`scripts/test-get-recommended-commit-title.ps1`、`scripts/test-validate-title.ps1` 等标题质量支持脚本）时，现在会再细化成 `review: refine DingTalk follow-up tracking and title automation`，把“提醒跟进记录”与“标题自动化收紧”从更泛的 workflow automation 修改里单独区分出来，避免这组维护继续长期挤在同一条 `fix: refine DingTalk state workflow automation and follow-up tracking` 标题上。针对最近又开始重复的另外两类维护组合，本轮还补了更窄的候选：`.github/workflows/title-quality.yml + Todo.md + WORKFLOW.md` 这一类标题质量维护组合，现在优先写成 `fix: refine title quality workflow guidance tests and backlog tracking`；而且这条规则不再只认三文件最小集合——如果同一批还顺手改到了 `COMMIT_MESSAGE_GUIDELINES.md`、`scripts/audit-title-history.ps1`、`scripts/get-recommended-commit-title.ps1`、`scripts/test-get-recommended-commit-title.ps1`、`scripts/test-validate-title.ps1` 这些标题质量相关文档/脚本，也会继续保持这条更具体的标题，避免一旦多带几个明显相关的支持文件就又退回泛化的 `fix: adjust repository automation ...`；同时现在还把这类标题质量巡检里常见的 `data/index/dingtalk-state.json`、`data/index/maintenance-log.md`、`data/index/task-board.md` backlog / 跟进状态文件也一起视为同一维护面，避免工作流调优时只要顺手更新了巡检记录或 DingTalk 跟进状态，就又误落回通用文档/自动化标题；同时也补认了仅以叶子文件路径出现的 `title-quality.yml`，避免某些脚本或平台把路径简写后又误落回通用文档/自动化标题。`auto-push.ps1 + resume-catchup.ps1 + Todo.md + WORKFLOW.md` 这类“同步兼容入口 + backlog 文档”组合则优先写成 `fix: refine sync entrypoint compatibility and workflow notes`，减少这两类“工作流/兼容入口 + backlog 文档”维护继续刷成泛化自动化标题。同时，`title-quality` workflow 现在不只回归测试标题校验器，也会额外跑 `scripts/test-get-recommended-commit-title.ps1`，确保高频组合的建议标题本身不会在后续重构时悄悄退化。最近又额外把生成器里的关键组合匹配收紧为同时兼容正斜杠、反斜杠与仅叶子文件名的输入，减少某些脚本/平台传入简写路径时，本该命中更具体规则的组合意外退回泛化标题。针对最近历史里仍偶尔冒头、但此前还没被单独命名的几类维护组合，本轮又继续补了更窄的规则：`Todo.md + data/index/dingtalk-state.json + maintenance-log.md` 这类“提醒状态跟进 + 维护记录”组合，现在优先写成 `review: track DingTalk reminder follow-up and maintenance notes`；`.gitignore + Todo.md + WORKFLOW.md` 这类“本机审计产物忽略规则 + backlog / 流程说明”组合，则优先写成 `chore: refine local audit artifact ignore rules and workflow notes`，避免它们再次回落成叶子文件枚举式的 `chore: adjust CET-6 repository files ...`。另外，这轮根据最近 60 条历史里两次仍落成 `sync: align CET-6 materials from D:\Bo` 的旧同步提交继续补了一个更窄的索引巡检规则：如果改动主要是 `data/index/` 下的共享状态 / 队列文件再配合标题审计支持脚本（例如 `scripts/audit-title-history.ps1`），且没有同时碰文档或学习计划，现在会优先落成 `review: refine DingTalk index tracking and title audit automation`（若未碰 `dingtalk-state.json`，则为 `review: refine index tracking and title audit automation`），把“索引状态跟进 + 标题审计自动化收紧”与更宽泛的 `sync: refresh CET-6 data and automation for ...` 区分开，减少这类技术上合规但信息量偏低的同步标题继续重复。最新一轮又根据真实重复热点补了一层更细的区分：当改动同时包含 `Todo.md + WORKFLOW.md + dingtalk-state.json`、脚本侧又只碰标题审计/标题生成支持脚本，而且数据文件仍全部局限在 `data/index/` 范围内时，现在会进一步优先落成 `review: refine DingTalk index follow-up guidance and title automation`，把“索引跟进说明 + backlog 文档 + 标题自动化收紧”与更宽泛的 `review: refine DingTalk follow-up tracking and title automation` 拆开，减少这类巡检提交继续稳定撞成同一条 PASS 标题。如果同一类 DingTalk 跟进 + 标题自动化维护额外带上的数据文件不再局限于 `data/index/`，而是只扩展到 `data/input/*` 训练输入（例如写作/翻译行数据），则现在会优先落成 `review: refine DingTalk follow-up guidance title automation and training inputs`，把“纯跟进/命名收紧”与“连带训练输入刷新”的提交进一步拆开。继续沿着这个重复热点往下拆后，当前又把另一类会混进同一条 `review:` 标题的语义单独拉出来：如果 `Todo.md + WORKFLOW.md + dingtalk-state.json` 搭配的额外 `data/index/*` 文件主要是 `discord-*` 学习流 / 快捷说明，再加标题生成支持脚本（以及常见的 `maintenance-log.md`、`task-board.md` 跟进文件），现在会优先落成 `review: refine DingTalk study flow guidance and title automation`，把“学习流说明更新 + 命名启发式收紧”与更泛的 DingTalk 跟进记录区分开，减少 `review: refine DingTalk follow-up tracking and title automation` 继续把不同语义的维护提交揉成一条标题。此次又补上了一处更隐蔽的路径形态漏口：`review: track DingTalk state follow-up and workflow notes`、`fix: refine sync entrypoint compatibility and workflow notes`、`chore: refine local audit artifact ignore rules and workflow notes` 这几条规则现在也不再只认完整相对路径，而是同样兼容 `dingtalk-state.json`、`resume-catchup.ps1`、`repo/.gitignore` 这类叶子名或带前缀路径输入，避免手工调用或外部脚本只传简写路径时，又被更早的文档/泛化分支截走并退回低信息量标题。

---

## 5. 钉钉提醒在流程中的位置

钉钉提醒不是仓库外的无关功能，而是项目的一部分。

其逻辑是：
- 仓库中保存一部分提醒所需的共享状态
- 另一个 OpenClaw 读取或更新这些状态
- 这些状态帮助提醒流程避免重复、保留上下文、维持执行连续性

因此，钉钉相关状态文件应视为：
- **项目运行状态**
- **跨 OpenClaw 协作状态**
- **可以进入仓库的项目数据**

而不是简单的临时缓存。

---

## 6. 为什么这个仓库必须“人能看懂”

如果一个项目只有 agent 能理解，人却要靠猜，那它会有几个问题：
- 新协作者接手困难
- PR 难审
- 状态文件容易被误删
- 自动化边界容易混乱
- 项目长期维护成本变高

所以这个仓库要求：

1. **目录命名尽量有意义**
2. **状态文件出现时要解释用途**
3. **自动化流程要有文字说明**
4. **不能把关键信息只藏在 agent 的记忆里**

---

## 7. PR 审查在流程里的位置

PR 审查的核心不是“代码能不能跑”，而是：
- 改动是否符合 CET-6 项目目标
- 是否破坏同步和协作流程
- 是否把私人/运行时/机器专属垃圾带进仓库
- 是否让项目变得更清楚，而不是更混乱

因此，这个仓库的 PR 审查同时看：
- 内容质量
- 项目边界
- 自动化兼容性
- 人类可理解性

---

## 8. 当前边界

### 默认允许进入仓库的内容
- CET-6 学习资料
- 学习计划
- 索引、任务板、跟踪器
- 项目运行必需的共享状态文件
- 项目文档
- 经确认的同步与自动化脚本

### 默认不应进入仓库的内容
- `.openclaw/`
- persona / memory / 私人配置
- 与项目无关的本机状态文件
- 密钥、token、账号凭据
- 没有文档解释且无法判断用途的噪音文件

---

## 9. 推荐阅读顺序

如果你刚进入这个仓库，建议按顺序看：

1. `README.md`
2. `WORKFLOW.md`
3. `SYNC_POLICY.md`
4. `PR_MERGE_POLICY.md`
5. `data/README.md`
6. `data/index/STATE_FILES.md`

这样能最快理解这个项目为什么存在、怎么协作、哪些文件重要。
