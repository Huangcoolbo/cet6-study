# CET-6 Task Board

## In Progress
- 继续筛选完整真题与答案来源
- 基于 `source-year-mapping.md` 继续补完整卷与答案解析缺口
- 按 `listening-verification-queue.md` 的顺位推进首个听力样本核验（先做 `2024-12 / KE / P1`）
- 维护 `catalog.md` / `source-year-mapping.md` / `verified-listening-samples.md` / `listening-verification-queue.md` 的状态一致性
- 等待首轮实际打卡数据，用于验证阶段性进度评估规则
- 基于 `transcripts/sample-intake-template.md` 统一后续听力样本核验与入库格式
- 继续观察钉钉链路稳定性，并等待用户确认作息窗口后做小范围真实提醒测试

## New Progress
- 已建立 `sources/complete-paper-candidates.md`，把完整试卷/答案来源与听力来源拆开管理
- 已新增 `index/starter-practice-packs.md`，基于本地 `input/` 数据源固定 5 个可直接在 Discord 主通道调用的 30 分钟微训练题包，作为真实听力样本核验前的开练兜底包
- 后续新增完整卷候选来源时，先登记到候选池，再决定是否写入正式索引
- 已补上 `daily-logs/2026-03.md`、`reviews/README.md`、`reviews/2026-W11-weekly-review.md`，让真实训练记录有固定落点
- 本轮根据现有进展补充了一个更具体的内部推进项：先整理“首批可直接训练的听力材料入口清单”，避免在完整卷来源尚未锁定时停滞
- 已新增 `sources/listening-entry-shortlist.md`，把 2024-12 → 2023 的听力入口按训练优先级固定下来
- 已新增 `index/verified-listening-samples.md` 与 `transcripts/README.md`，把“入口清单”和“已核验可训练样本”正式拆开管理
- 已补 `transcripts/sample-intake-template.md`，把后续听力样本核验与入库字段固定下来
- 已修正首批听力推进文档中的相对路径/文件名引用不一致问题，减少后续核验时的伪阻塞
- 本轮巡检确认：`verified-listening-samples.md` 仍全部处于 `pending`，暂无可上调为 `verified` 的样本；已把“状态一致性维护”明确列为持续内部任务，避免后续进度虚高
- 2026-03-14 晚间内部巡检：Todo、任务板、catalog、source-year-mapping、verified-listening-samples 之间当前未发现新的路径/状态冲突；因此不人为上调任何资料状态，继续把首个真实推进点锁定为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-14 21:22 cron 巡检：复查上述索引与入口文件后，确认本轮仍无可安全完成的“状态升级”动作；继续维持现状，避免把未核验入口包装成真实样本进展
- 2026-03-14 21:27 cron 巡检：在无新增外部核验结果的前提下，不上调任何年份/样本状态；已在 `index/verified-listening-samples.md` 补上 `pending → verified → trained` 的统一回写规则，减少后续状态口径漂移
- 2026-03-14 21:32 cron 巡检：复查 `Todo.md`、`index/task-board.md`、`index/catalog.md`、`index/source-year-mapping.md`、`index/verified-listening-samples.md`、`sources/listening-entry-shortlist.md`、`transcripts/sample-intake-template.md` 后，未发现新的可安全完成项；本轮继续只做状态一致性确认，不补伪进展，真实推进点仍是 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-14 21:37 cron 巡检：再次按实际 `index/` 路径复查 `catalog.md`、`source-year-mapping.md`、`verified-listening-samples.md` 与 `Todo.md`、`sources/listening-entry-shortlist.md`、`transcripts/sample-intake-template.md`，确认本轮仍无可安全上调的样本或年份状态；继续维持“只记真实核验结果，不做状态虚增”的口径，下一真实推进点不变
- 2026-03-14 21:42 cron 巡检：继续复查 `Todo.md`、`index/task-board.md`、`index/catalog.md`、`index/source-year-mapping.md`、`index/verified-listening-samples.md`、`sources/listening-entry-shortlist.md` 与 `transcripts/sample-intake-template.md`，仍未发现新的可安全完成项；本轮只做状态一致性回写，不补重复任务，真实推进点继续锁定为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-14 21:47 cron 巡检：再次对照 `Todo.md`、`index/task-board.md`、`index/catalog.md`、`index/source-year-mapping.md`、`index/verified-listening-samples.md`、`sources/listening-entry-shortlist.md` 与 `transcripts/sample-intake-template.md`，仍无新的可安全完成项；本轮仅补记“无实质变化”，不重复新增同类任务，下一真实推进点保持不变
- 2026-03-14 21:52 cron 巡检：继续复查 `Todo.md`、`index/task-board.md`、`index/catalog.md`、`index/source-year-mapping.md`、`index/verified-listening-samples.md`、`sources/listening-entry-shortlist.md` 与 `transcripts/sample-intake-template.md`，仍未发现新的可安全完成项；本轮仅同步“无实质变化”的状态回写，不重复补同类后续任务，真实推进点继续锁定为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-14 21:57 cron 巡检：在不伪造样本核验进展的前提下，新增 `index/listening-verification-queue.md`，把 P1/P2/P3 的实际核验顺位与最小检查项固定下来；本轮推进的是执行口径收紧，不是状态升级，首个真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-14 22:02 cron 巡检：新增 `index/maintenance-log.md`，把后续高频“无实质变化”的一致性巡检从主任务板分流记录，避免主线文件持续膨胀；本轮未上调任何样本/年份状态，真实推进点仍不变
- 2026-03-14 22:32 cron 巡检：在不依赖外部核验的前提下，补建 `index/discord-study-flow.md`，先把 Discord 主学习通道的“开始今日六级”入口、30 分钟任务下发骨架、每日提交格式与严格监督型反馈顺序固定下来；本轮推进的是主通道最小闭环设计，不涉及听力样本状态升级，资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 13:34 cron 巡检：继续沿 Discord 主通道建设推进，新增 `skills/cet6-coach/references/discord-main-channel.md`，并在 `cet6-coach/SKILL.md` 的 Daily practice mode 中补上 Discord 主学习通道接线说明；本轮真实完成的是“将 Discord 主通道规则接入 cet6-coach 或相关参考文件”，不涉及资料核验状态升级，听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 13:39 cron 巡检：继续按 Discord 主学习通道建设推进，新增 `index/discord-listening-flow.md`，把 `今日听力` / 听力版 `开始今日六级` 的 30 分钟任务骨架、分轮提交格式、错因追问逻辑与严格监督型完成判定固定下来；Todo 中“设计 Discord 听力专项互动流程”已改为完成。该动作属于内部流程补全，不涉及任何资料样本状态升级，听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 13:44 cron 巡检：继续沿 Discord 主学习通道补齐专项流程，新增 `index/discord-translation-flow.md` 与 `index/discord-writing-flow.md`，分别把 `今日翻译` / `今日写作` 的 30 分钟任务骨架、分轮提交格式、错因追问逻辑与严格监督型完成判定固定下来；Todo 中“设计 Discord 翻译专项互动流程”“设计 Discord 写作专项互动流程”已改为完成。该动作属于内部流程补全，不涉及任何资料样本状态升级，听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 13:49 cron 巡检：继续沿 Discord 主学习通道补齐快捷入口，新增 `index/discord-shortcuts.md`，把 `查看计划` / `查看弱项` / `今日复盘` 的标准返回模板、数据读取顺序、无真实数据时的默认回退口径固定下来；Todo 中“设计 Discord 弱项查询 / 今日复盘 / 查看计划 等快捷入口”已改为完成。该动作属于内部流程补全，不涉及任何资料样本状态升级，听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 14:14 cron 巡检：复查 `Todo.md`、`index/task-board.md`、`index/discord-shortcuts.md`、`reviews/2026-W11-weekly-review.md` 与 `index/stage-progress-evaluation.md` 后，确认当前可安全推进的内部动作是先补“查看本周进度”的周级快捷入口骨架，而不是继续重复扩写日级模板；本轮新增 `index/discord-weekly-progress-shortcut.md`，明确其取数顺序、标准返回结构与“无真实数据不伪造统计”的口径，并将 Todo 对应设计项补记为完成。该动作属于内部流程补全，不涉及任何资料样本状态升级；听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 14:19 cron 巡检：复查 `Todo.md`、`cet6-coach/SKILL.md`、`skills/cet6-coach/references/discord-shortcuts.md` 与 `index/discord-weekly-progress-shortcut.md` 后，确认“查看本周进度”虽已设计，但仍未正式接入 skill 参考层；本轮新增 `skills/cet6-coach/references/discord-weekly-progress.md`，并在 `SKILL.md` 中补上 Discord 周级入口读取说明，同时将 Todo 中对应接线项记为完成，并把任务板中已过时的“再补查看本周进度入口”改写为“待真实周数据后收紧字段口径”。该动作属于内部流程收口，不涉及任何资料样本状态升级；听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 14:24 cron 巡检：复查 `Todo.md`、`index/reminder-plan.md`、`index/automation-evaluation.md`、`index/reminder-copy-style.md`、`index/dingtalk-state.json` 与 `index/dingtalk-task.log` 后，确认当前可安全完成的内部推进项是先把钉钉订阅的控制面补齐，而不是继续停留在“只有发送日志”的状态；本轮新增 `index/dingtalk-subscription-controls.md`，将 `start / pause / resume` 控制动作、`contentTypes / schedule` 配置入口与 `dingtalk-state.json` 的状态结构固定下来，并同步将 Todo 中两项钉钉订阅后续记为完成。该动作属于内部自动化设计收口，不涉及任何资料样本状态升级；听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 14:34 cron 巡检：复查 `Todo.md`、`skills/cet6-coach/SKILL.md`、`skills/cet6-coach/references/discord-main-channel.md`、`cet6-data/index/discord-listening-flow.md`、`cet6-data/index/discord-writing-flow.md` 与 `cet6-data/index/discord-translation-flow.md` 后，确认当前尚未正式收口、但可安全完成的内部缺口，是把 `今日听力` / `今日写作` / `今日翻译` 三类 Discord 专项入口正式接到 `cet6-coach` 参考层，而不是继续让它们只停留在索引文档里；本轮新增 `skills/cet6-coach/references/discord-specialized-flows.md`，并在 `SKILL.md` 的 Daily practice mode 中补上专项入口读取说明，同时将 Todo 对应接线项记为完成。该动作属于内部流程收口，不涉及任何资料样本状态升级；听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 14:39 cron 巡检：复查 `Todo.md`、`skills/cet6-coach/SKILL.md`、`skills/cet6-coach/references/discord-main-channel.md` 与 `cet6-data/index/discord-scoring-review-format.md` 后，确认当前还未正式接入 skill 参考层、但可安全完成的内部缺口，是把 Discord 的每日评分 / 复盘口径从数据层索引上收口到 `cet6-coach` 通道规则层；本轮新增 `skills/cet6-coach/references/discord-scoring-review.md`，并在 `SKILL.md` 与 `references/discord-main-channel.md` 中补上评分入口读取说明，同时将 Todo 对应接线项记为完成。该动作属于内部流程收口，不涉及任何资料样本状态升级；听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验
- 2026-03-15 14:49 cron 巡检：复查 `Todo.md`、`cet6-data/index/starter-practice-packs.md`、`cet6-data/index/discord-study-flow.md`、`skills/cet6-coach/references/discord-main-channel.md` 与 `skills/cet6-coach/references/discord-specialized-flows.md` 后，确认当前最合理且可安全完成的内部缺口，是把“真实听力样本未核验时如何用本地微训练题包兜底开练”正式接入 Discord / `cet6-coach` 通道参考层，并顺手清理主通道文档里已过时的“待扩展 / 待设计”描述；本轮已将 `starter-practice-packs.md` 的回退规则补入上述参考文件，并将 Todo 对应项记为完成。该动作属于内部流程收口，不涉及任何资料样本状态升级；听力资料主线的真实推进点仍为 `2024-12 / KE / P1` 的实际入口核验

## Next
- 先核验 `sources/listening-entry-shortlist.md` 中的 P1 入口（`2024-12 / KE`），再推进 P2/P3，并把首批结果写入 `index/verified-listening-samples.md`
- 核验时严格按 `index/listening-verification-queue.md` 与 `transcripts/sample-intake-template.md` 执行，先形成最小样本记录，再决定是否上调 `catalog.md`
- 持续维护索引层的一致性（`catalog.md` / `source-year-mapping.md` / `verified-listening-samples.md` / `listening-verification-queue.md` 的相互引用），不把入口状态误写成样本状态
- 扩充并优化输入数据源，继续向写作 / 翻译弱项倾斜
- 用真实打卡数据填充首轮每日记录，并完成一份周复盘
- 等首个真实听力样本核验成功后，把 `index/starter-practice-packs.md` 中对应 Pack 的听力块替换为真实材料页任务
- 用周数据跑一次阶段性评估
- 等首轮真实打卡数据出现后，收紧 Discord 快捷入口与评分回退口径，减少“待补真实数据”占比
- 等首轮真实周数据出现后，收紧“查看本周进度”的字段与判断口径，并与周复盘 / 阶段评估口径继续打通
- 在用户确认作息窗口后，做一次小范围提醒测试

## Blocked
- 完整真题与答案的高可信来源仍需继续筛选
- 资料正文尚未批量入库，当前以索引和来源层为主
- 提醒稳定触达尚未实测，当前只完成内部设计，未进行外部触发验证

## Done
- 创建 `cet6-coach` 初版 skill
- 记录用户基础画像
- 配置 Tavily 恢复联网搜索
- 建立阶段性进度评估规则
- 完成提醒方案、提醒文案风格与 cron 启用评估文档
- 完成来源-年份映射初版并更新 catalog
