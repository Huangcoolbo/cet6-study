# CET-6 首批可直接使用的微训练题包

## 目的

在听力真题样本尚未完成首轮真实核验前，先基于 `../input/` 里的本地数据源生成一批**可立即调用、可直接在 Discord 主通道执行**的 30 分钟微训练题包。

这批题包的定位不是替代真题，而是：
1. 让系统在无外部新增资料的情况下也能稳定开练
2. 把“严格监督型 30 分钟流程”落到可直接发出的具体题目
3. 为后续真实听力样本接入前，提供低摩擦的启动包与兜底包

---

## 使用原则

- 优先用于：用户当天要开练，但真实听力样本尚未核验完毕时
- 不宣称为真题；统一表述为“微训练题包”或“本地训练包”
- 每次只取 1 包，不混发太多内容
- 做完后仍按 `discord-main-channel.md` / `discord-scoring-review.md` 的评分与复盘顺序执行
- 一旦 `verified-listening-samples.md` 出现真实可训练样本，听力主块应优先切回真实样本

---

## 题包结构（统一模板）

每包默认对应 30 分钟：
1. 5 分钟：词汇预热
2. 10 分钟：听力 paraphrase / 信号词识别
3. 10 分钟：翻译或写作微输出
4. 5 分钟：回收表达 + 严格评分

---

## Pack 01｜稳态启动包

### 词汇预热（英译中 / 造短句二选一）
- sustain
- crucial
- evaluate
- consistent
- motivate

### 听力 paraphrase 识别
请判断下列替换是否表达同一核心意思，并说出中文提示：
- important → crucial / essential / significant
- improve → enhance / promote / boost
- result → outcome / consequence / effect
- need → require / be in need of / call for

### 翻译微输出（中译英）
- 坚持不是一时冲动，而是长期选择。
- 时间管理决定你能走多远。

### 写作微输出（2 句）
围绕“consistent practice”写 2 句，必须至少使用：
- essential
- improve

### 结束时必须检查
- 是否把 `important / improve / need` 的替换说清
- 是否出现中式直译
- 是否有 1 个可回收表达写入 `../input/expressions.tsv` 候选池

---

## Pack 02｜听力优先包

### 词汇预热
- frequent
- relevant
- reliable
- precise
- concentrate

### 听力 paraphrase 识别
- help → assist / support / be of help to
- because → since / as / due to the fact that
- quickly → rapidly / promptly / in a short time
- choose → select / opt for / pick

### 精听式文字任务
看下面句子，先划出关键词，再口头或文字复述核心信息：
- Compared with passive input, active output leaves a deeper impression.
- The earlier we correct our mistakes, the faster we improve.

### 翻译微输出
- 有效的学习依赖重复和反思。
- 及时复盘错误能提高学习效率。

### 结束时必须检查
- 是否能识别比较结构与 the + 比较级 的句型
- 是否把 passive input / active output 译自然
- 是否能说出至少 2 个听力错因风险点（如替换不敏感、比较结构漏听）

---

## Pack 03｜写译强化包

### 词汇预热
- beneficial
- practical
- flexible
- significant
- transform

### 听力 paraphrase 识别
- show → demonstrate / indicate / reveal
- problem → issue / difficulty / challenge
- start → begin / commence / set out

### 翻译微输出
- 真正的问题不是起点低，而是不能坚持。
- 正确的方法能让有限时间更高效。

### 写作微输出（3 句小段）
主题：Why a clear goal matters in CET-6 study
必须包含：
- One of the main reasons is that ...
- More importantly, ...
- practical / efficient 二选一

### 结束时必须检查
- 是否能把“不是……而是……”处理成自然英文
- 是否有句子只会堆形容词、没有清晰主干
- 是否完成 1 次自改，而不是交初稿就结束

---

## Pack 04｜纪律执行包

### 词汇预热
- strategy
- maintain
- resource
- effective
- participate

### 听力 paraphrase 识别
- think → believe / suppose / hold the view that
- useful → beneficial / helpful / valuable
- common → widespread / shared / frequent
- change → alter / transform / modify

### 句子理解与复述
- More importantly, a clear plan helps us use limited time wisely.
- Instead of waiting for motivation, we should rely on discipline.

### 翻译微输出
- 清晰的目标会让努力更聚焦。
- 持续输入和稳定输出同样重要。

### 结束时必须检查
- 是否能解释 instead of 结构
- 是否把 rely on discipline 说成自然表达
- 是否明确写出今日最低问题：词汇、句法还是表达自然度

---

## Pack 05｜首轮复盘包

### 词汇预热
- constructive
- meaningful
- independent
- gradual / gradually
- suitable

### 听力 paraphrase 识别
- result → outcome / consequence / effect
- improve → enhance / promote / boost
- help → assist / support / be of help to

### 句子改写
请把下列句子各改写 1 次，不改变原意：
- Only by taking action can we turn goals into real progress.
- It is not enough to understand a point once; we must review it repeatedly.

### 写作微输出（2-3 句）
主题：How to use 30 minutes well every day
必须包含：
- review
- meaningful / practical 二选一

### 结束时必须检查
- 是否正确处理倒装 Only by ... can we ...
- 是否把 once / repeatedly 的对比写清
- 是否能从本包中回收 1 条适合写入 `writing-lines.tsv` 的句子

---

## Discord 调用建议

当用户说：
- `开始今日六级`：若真实样本暂未就位，可先从 Pack 01 / 02 / 03 中按弱项选 1 包
- `今日听力`：优先 Pack 02，其次 Pack 04
- `今日写作`：优先 Pack 03，其次 Pack 05
- `今日翻译`：优先 Pack 01 / 03 / 04

建议轮换：
- 周一：Pack 01
- 周二：Pack 02
- 周三：Pack 03
- 周四：Pack 04
- 周五：Pack 05
- 周末：按本周错因回抽 1 包，不新增包号

---

## 与主线资料的关系

- 这份文件解决的是“现在就能练什么”
- `verified-listening-samples.md` 解决的是“哪些真实听力样本已核验可训练”
- 后续一旦出现真实样本，本文件中的听力块应逐步被真实样本替换；但词汇、写作、翻译微输出部分仍可继续复用

---

## 下一步

1. 先把这 5 个包接入任务板，作为“可立即调用的首批训练题包”
2. 等首个真实听力样本核验成功后，把对应 Pack 的听力块替换成真实材料页任务
3. 等用户出现首轮真实打卡数据后，再根据常错点重排 Pack 顺序与难度
