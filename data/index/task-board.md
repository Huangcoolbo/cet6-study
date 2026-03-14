# CET-6 Task Board

## In Progress
- 继续筛选完整真题与答案来源
- 基于 `source-year-mapping.md` 继续补完整卷与答案解析缺口
- 开始沉淀听力原文样本
- 为每日训练生成首批可直接使用的题目
- 等待首轮实际打卡数据，用于验证阶段性进度评估规则
- 基于 `transcripts/sample-intake-template.md` 统一后续听力样本核验与入库格式

## New Progress
- 已建立 `sources/complete-paper-candidates.md`，把完整试卷/答案来源与听力来源拆开管理
- 后续新增完整卷候选来源时，先登记到候选池，再决定是否写入正式索引
- 已补上 `daily-logs/2026-03.md`、`reviews/README.md`、`reviews/2026-W11-weekly-review.md`，让真实训练记录有固定落点
- 本轮根据现有进展补充了一个更具体的内部推进项：先整理“首批可直接训练的听力材料入口清单”，避免在完整卷来源尚未锁定时停滞
- 已新增 `sources/listening-entry-shortlist.md`，把 2024-12 → 2023 的听力入口按训练优先级固定下来
- 已新增 `index/verified-listening-samples.md` 与 `transcripts/README.md`，把“入口清单”和“已核验可训练样本”正式拆开管理
- 已补 `transcripts/sample-intake-template.md`，把后续听力样本核验与入库字段固定下来
- 已修正首批听力推进文档中的相对路径/文件名引用不一致问题，减少后续核验时的伪阻塞
- 本轮巡检确认：`verified-listening-samples.md` 仍全部处于 `pending`，暂无可上调为 `verified` 的样本；已把“状态一致性维护”明确列为持续内部任务，避免后续进度虚高

## Next
- 先核验 `sources/listening-entry-shortlist.md` 中的 P1/P2 入口，并把首批结果写入 `index/verified-listening-samples.md`
- 持续维护索引层的一致性（`catalog.md` / `source-year-mapping.md` / `verified-listening-samples.md` 的相互引用），不把入口状态误写成样本状态
- 用真实打卡数据填充首轮每日记录，并完成一份周复盘
- 用周数据跑一次阶段性评估
- 基于真实打卡数据，决定是否启用 cron 固定提醒
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
