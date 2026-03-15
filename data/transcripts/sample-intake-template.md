# 听力样本入库模板

> 用途：当某个听力入口已从 `pending` 推进到可落地的具体样本时，先按本模板登记，再决定是否整理为完整 transcript。

---

## 基本信息

- 年份/批次：
- 套卷/题型：
- 来源站点：
- 入口文件：`../sources/listening-entry-shortlist.md`
- 来源页面 URL：
- 当前状态：`verified` / `trained` / `blocked`
- 资料等级：`A` / `B` / `C`

## 可用性核验

- 入口是否可访问：是 / 否
- 是否能定位到具体样本页：是 / 否
- 是否有原文：完整 / 部分 / 无
- 是否有题目或讲解：完整 / 部分 / 无
- 年份/批次标注是否清晰：清晰 / 存疑 / 混乱
- 是否适合直接纳入 30 分钟训练：是 / 否

## 训练用途

- 可做动作：精听 / paraphrase 识别 / 关键词预热 / 复述 / 错因分析
- 推荐训练时长：5 分钟 / 10 分钟 / 15 分钟
- 适合放入的训练位置：开场预热 / 主任务 / 复盘补充

## 本样本的最小记录

- 主题/段落：
- 关键词：
- 易错点：
- 可回收表达：
- 与 `input/listening-paraphrases.tsv` 是否联动：是 / 否
- 与当前月份对应的 `daily-logs/YYYY-MM.md`（例如 `daily-logs/2026-03.md`）是否已有训练记录：是 / 否

## 处理结论

- 结论：继续入库 / 可直接训练 / 暂时阻塞 / 放弃
- 阻塞原因（如有）：
- 下一步动作：
- 对 `index/verified-listening-samples.md` 的回写内容：
- 对 `index/catalog.md` 的状态影响：

---

## 命名建议

- 若已确认是完整原文：`<year>-<month>-set<1|2|3>-transcript.md`
- 若只是首批训练切片：`<year>-<month>-sample-<topic>.md`

示例：
- `2024-12-sample-news-listening.md`
- `2024-12-set1-transcript.md`
