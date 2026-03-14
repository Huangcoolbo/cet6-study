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
- [~] 观察 `.github/workflows/title-quality.yml` 的实际误报/漏报情况，必要时调整标题校验规则，避免把合理提交拦得过死。（已补 `scripts/test-validate-title.ps1` 做首轮样本回归，并已放行正常 merge commit / 初始化历史标题；已根据真实 git 历史补放行 `Merge master into main` 这类正常合并标题；已把历史中的旧式大写 `Update ...` 标题加入失败回归样本，确认未来调规则时不会误放宽；本轮又把回归样本接入 CI 工作流自身，并补了 `docs: README` / `fix: typo` / `chore: cleanup` 这类常见过短或空泛标题的失败样本；后续继续结合真实 PR / push 记录观察）
