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
- [~] 观察 `.github/workflows/title-quality.yml` 的实际误报/漏报情况，必要时调整标题校验规则，避免把合理提交拦得过死。（已补 `scripts/test-validate-title.ps1` 做首轮样本回归，并已放行正常 merge commit / 初始化历史标题；已根据真实 git 历史补放行 `Merge master into main` 这类正常合并标题；已把历史中的旧式大写 `Update ...` 标题加入失败回归样本，确认未来调规则时不会误放宽；已把回归样本接入 CI 工作流自身，并补了 `docs: README` / `fix: typo` / `chore: cleanup` 这类常见过短或空泛标题的失败样本；本轮又根据用户偏好收紧规则，新增“禁止日期/时间戳出现在 commit / PR 标题中”的校验与回归样例，并把回归脚本改成直接调用 `validate-title.ps1`，避免在当前环境里通过嵌套 `pwsh` 调用时偶发卡住；本次又根据真实仓库历史发现 `sync-cet6-study.ps1` 仍会生成不带 `<type>:` 前缀的旧式标题，因此已改为产出符合规则的 `data:` / `plan:` / `docs:` / `fix:` / `sync:` / `chore:` 标题，并把对应正反样例补进回归；又把真实历史中的 `update CET-6 study data and DingTalk reminder state; clarify project documentation; adjust repository automation` 这类“多类改动硬串在一个无前缀标题里”的旧样式补进失败回归，防止后续为放宽规则而误放行；本轮继续根据真实 git 历史补抓到 `chore: update CET-6 repository files ...` 这类仍会被校验器判定为“summary 以空泛 update 开头”的旧兜底样式，已把自动同步脚本兜底标题改成 `chore: adjust ...` 并在提交前先调用 `scripts/validate-title.ps1` 做自检，避免再次自动产出不合规标题；本轮又补了 `scripts/audit-title-history.ps1`，可直接批量审计最近真实 commit 历史并输出 PASS / FAIL + 原因，减少后续观察误报/漏报时只靠人工翻 log；已本地抽查最近 12 条历史，当前命中的主要仍是旧时间戳/旧无前缀/旧 `update ...` 标题，暂未看到新的明显误杀样例；后续继续结合真实 PR / push 记录观察）
- [x] 核对本机定时任务/恢复脚本是否仍在调用会产出旧式提交标题的历史版本，避免仓库继续被自动写入已被 CI 判定为不合规的 commit 标题。（已直接查询当前注册的 `CET6StudyAutoPush` / `CET6StudyResumeCatchup` 计划任务 XML，确认它们都指向 `D:\Ying` 下现行脚本：前者执行 `auto-push.ps1` 兼容包装层，后者执行 `resume-catchup.ps1` 且后续调用 `sync-cet6-study.ps1`；未发现仍指向旧目录或历史副本的已注册本机入口；并补了 `scripts/audit-sync-entrypoints.ps1` 便于后续重复核对）
- [x] 评估是否要把 `CET6StudyAutoPush` 计划任务的动作从 `auto-push.ps1` 兼容包装层进一步收敛为直接调用 `sync-cet6-study.ps1`，减少一层历史兼容入口并降低后续漂移风险。（结论：值得收敛；已补 `scripts/set-autopush-task-entrypoint.ps1` 作为可重复执行的迁移脚本，并更新 `scripts/audit-sync-entrypoints.ps1` / `WORKFLOW.md` 区分“首选主入口”与“兼容回退入口”）
- [x] 选择合适窗口执行 `scripts/set-autopush-task-entrypoint.ps1`，把本机 `CET6StudyAutoPush` 计划任务从兼容包装层正式切换为直接调用 `sync-cet6-study.ps1`，然后再次审计确认落地结果。（已执行迁移脚本并复跑 `scripts/audit-sync-entrypoints.ps1`，当前 `CET6StudyAutoPush` / `CET6StudyResumeCatchup` 均通过审计）
- [x] 清理计划任务审计过程中产生的本机 XML 快照边界，避免 `*.current.xml` / 导出任务定义被误当成仓库待提交内容。（已在 `.gitignore` 中忽略这类本机计划任务导出产物）
