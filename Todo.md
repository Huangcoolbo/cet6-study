# Todo

使用规则：
- 只记录仍然需要处理的任务
- 每条任务都要带状态
- 新发现的后续任务，也要补到这里
- 完成后把状态改掉，不要假装记住

## Status
- [ ] 未完成
- [~] 进行中
- [x] 已完成
- [-] 暂不处理

## Tasks
- [x] 为 `data/index/dingtalk-state.json` 补充字段级说明，解释每个字段的含义、用途、读写方与删除影响。
- [x] 新增贡献指南，说明其他账号如何提交 PR、哪些内容允许进入仓库、哪些内容不要提交。
- [x] 校正 `data/README.md`，补上 `input/` 的实际角色，并区分“当前已存在目录”与“规划中的资料目录”。
- [x] 修复 `sync-cet6-study.ps1` 在上游路径缺失时可能因 `Get-Item` 直接报错的问题，使缺失源路径按预期跳过。
- [x] 评估 `auto-push.ps1` 与 `sync-cet6-study.ps1` 的职责重叠，决定收敛为以 `sync-cet6-study.ps1` 为主入口，并把 `auto-push.ps1` 降级为兼容包装脚本，同时补充说明以避免后续维护混乱。
- [ ] 持续检查项目职责范围内是否还有未完成事项；如发现新的任务，补充到本文件。
- [x] 制定更具体的 git commit message 规范，避免使用过于笼统的提交描述，并且不要包含时间戳。
- [x] 修复自动同步脚本仍在使用硬编码旧提交信息模板的问题，改为根据实际变更生成更具体、易懂的 commit message。
- [x] 评估是否需要把 `COMMIT_MESSAGE_GUIDELINES.md` 的约束进一步体现在自动化脚本或 PR 模板中，避免规范只停留在文档层。
- [x] 评估是否要进一步加入可执行的 commit / PR 标题校验（如本地 hook、GitHub Action 或审查脚本），把当前 PR 模板中的软约束升级为可检查规则。
- [~] 观察 `.github/workflows/title-quality.yml` 的实际误报/漏报情况，必要时调整标题校验规则，避免把合理提交拦得过死。（已补 `scripts/test-validate-title.ps1` 做首轮样本回归，并已放行正常 merge commit / 初始化历史标题；已根据真实 git 历史补放行 `Merge master into main` 这类正常合并标题；已把历史中的旧式大写 `Update ...` 标题加入失败回归样本，确认未来调规则时不会误放宽；已把回归样本接入 CI 工作流自身，并补了 `docs: README` / `fix: typo` / `chore: cleanup` 这类常见过短或空泛标题的失败样本；本轮又根据用户偏好收紧规则，新增“禁止日期/时间戳出现在 commit / PR 标题中”的校验与回归样例，并把回归脚本改成直接调用 `validate-title.ps1`，避免在当前环境里通过嵌套 `pwsh` 调用时偶发卡住；本次又根据真实仓库历史发现 `sync-cet6-study.ps1` 仍会生成不带 `<type>:` 前缀的旧式标题，因此已改为产出符合规则的 `data:` / `plan:` / `docs:` / `fix:` / `sync:` / `chore:` 标题，并把对应正反样例补进回归；又把真实历史中的 `update CET-6 study data and DingTalk reminder state; clarify project documentation; adjust repository automation` 这类“多类改动硬串在一个无前缀标题里”的旧样式补进失败回归，防止后续为放宽规则而误放行；本轮继续根据真实 git 历史补抓到 `chore: update CET-6 repository files ...` 这类仍会被校验器判定为“summary 以空泛 update 开头”的旧兜底样式，已把自动同步脚本兜底标题改成 `chore: adjust ...` 并在提交前先调用 `scripts/validate-title.ps1` 做自检，避免再次自动产出不合规标题；本轮又补了 `scripts/audit-title-history.ps1`，可直接批量审计最近真实 commit 历史并输出 PASS / FAIL + 原因，减少后续观察误报/漏报时只靠人工翻 log；这次继续把审计脚本增强为支持失败原因聚合摘要与 `-FailuresOnly` 只看失败项，并新增 `-SummaryOnly` / `-AsJson` 便于后续在巡检或 CI 中复用摘要结果；本地复跑 `scripts/test-validate-title.ps1` 29 个样例全部通过，并再次抽查最近 25 条历史：当前失败仍集中在已知历史遗留坏标题桶，最新一轮为 8 条带时间戳、3 条缺少 `<type>:` 前缀、2 条 `chore: update ...` 式空泛 summary，`audit-title-history.ps1 -SummaryOnly` 现会明确给出 `Outcome: legacy-only` / `Suggested action`，暂未看到新的明显误杀样例；后续继续结合真实 PR / push 记录观察）
- [x] 核对本机定时任务/恢复脚本是否仍在调用会产出旧式提交标题的历史版本，避免仓库继续被自动写入已被 CI 判定为不合规的 commit 标题。（已直接查询当前注册的 `CET6StudyAutoPush` / `CET6StudyResumeCatchup` 计划任务 XML，确认它们都指向 `D:\Ying` 下现行脚本：前者执行 `auto-push.ps1` 兼容包装层，后者执行 `resume-catchup.ps1` 且后续调用 `sync-cet6-study.ps1`；未发现仍指向旧目录或历史副本的已注册本机入口；并补了 `scripts/audit-sync-entrypoints.ps1` 便于后续重复核对）
- [x] 评估是否要把 `CET6StudyAutoPush` 计划任务的动作从 `auto-push.ps1` 兼容包装层进一步收敛为直接调用 `sync-cet6-study.ps1`，减少一层历史兼容入口并降低后续漂移风险。（结论：值得收敛；已补 `scripts/set-autopush-task-entrypoint.ps1` 作为可重复执行的迁移脚本，并更新 `scripts/audit-sync-entrypoints.ps1` / `WORKFLOW.md` 区分“首选主入口”与“兼容回退入口”）
- [x] 选择合适窗口执行 `scripts/set-autopush-task-entrypoint.ps1`，把本机 `CET6StudyAutoPush` 计划任务从兼容包装层正式切换为直接调用 `sync-cet6-study.ps1`，然后再次审计确认落地结果。（已执行迁移脚本并复跑 `scripts/audit-sync-entrypoints.ps1`，当前 `CET6StudyAutoPush` / `CET6StudyResumeCatchup` 均通过审计）
- [x] 清理计划任务审计过程中产生的本机 XML 快照边界，避免 `*.current.xml` / 导出任务定义被误当成仓库待提交内容。（已在 `.gitignore` 中忽略这类本机计划任务导出产物）
- [x] 评估是否要把 `scripts/audit-title-history.ps1 -AsJson` 接到后续巡检/CI 产物里，减少人工抄录标题审计摘要。（结论：值得接入；已把 push 范围的 JSON 审计结果接到 `.github/workflows/title-quality.yml`，并作为 `title-audit-summary` artifact 上传，便于后续下载复核）
- [~] 观察 `title-audit-summary` artifact 在真实 push 场景中的可读性与复用价值；如果后续巡检仍需要人工二次整理，再决定是否继续压缩摘要格式或补更多机器可消费字段。（已先把 `scripts/audit-title-history.ps1` 扩展为支持 `-AsMarkdown`，并让 `.github/workflows/title-quality.yml` 在 push 后同时产出 JSON + Markdown artifact，且把 Markdown 摘要直接写入 workflow step summary；本轮又补了 `-Compact` 模式，让 workflow summary 默认只显示统计 + 失败原因聚合，同时把完整逐条 Markdown 明细单独保留为 artifact，减少真实 push 时 summary 过长、还得人工扫完整列表的问题；本轮继续把“全绿”场景补得更直白：Markdown 摘要现在在 0 个失败时也会显式写出 `No failing titles found in this audit slice.`，并把失败原因计数里的 Unicode 乘号替换成 ASCII `x`，避免部分终端/日志编码下出现乱码；这次又把 JSON/控制台摘要往“可直接判断是否要继续追查”推进了一步：新增 `Outcome` 字段，并在每类失败原因下附少量示例标题，减少后续还得先翻完整明细才能判断是不是单纯命中历史遗留坏标题；本轮继续补了 `SuggestedAction` 提示，让 JSON / Markdown / 控制台摘要都能直接给出“无需跟进 / 仅需确认仍属历史坏标题 / 可能出现新规则问题”的下一步建议，进一步降低每次巡检先打开完整明细再判断的成本；本轮又根据真实历史抽查发现 `SuggestedAction` 对“仅命中已知历史坏标题桶”的识别过于脆弱，会把纯历史遗留问题误报成“存在新问题”，现已把失败原因归一化逻辑改成按已知模式稳定归类，并复跑最近 25 条历史确认摘要会正确提示“仍属已知 legacy bad-title buckets”；这轮又补了文档说明，明确 `Outcome` 现在分为 `clean` / `legacy-only` / `needs-review` 三种，避免后续看 workflow summary 或 artifact 时把“仅命中历史坏标题”误读成“完全无失败”或“出现新规则问题”；本轮继续把“这次到底审计了哪一段历史”也直接塞进摘要：JSON / Markdown / 控制台现都会输出 `AuditScope`（如 `latest 25 commits` 或具体 `revision range <before>..<after>`），减少后续看 artifact 时还得反推参数来源；后续重点观察这种“短摘要 + 审计范围 + 失败示例 + 下一步建议 + 全量明细附件”的组合是否已经足够替代人工二次整理）
