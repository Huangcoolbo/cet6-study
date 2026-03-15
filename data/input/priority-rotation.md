# CET-6 输入池首轮高优先级轮换清单

## 目的

在 `writing-lines.tsv`、`translation-lines.tsv`、`expressions.tsv` 已连续扩充三轮后，先从现有输入池中筛出一批**高复用、低歧义、可直接服务 30 分钟严格监督型训练**的核心条目，作为后续 Discord 主通道、微训练题包和提醒文案的优先调用层。

这份清单不是替代原始 TSV，而是做一层轻量收口：
- 避免每次都从全量 TSV 临时挑句子
- 避免同类近义句被反复轮换，导致训练表面变化、实质重复
- 在真实打卡数据出现前，先把当前最稳的弱项素材固定下来

---

## 使用原则

- 优先用于：`开始今日六级`、`今日写作`、`今日翻译`、微训练题包补位
- 不追求数量，先保留最容易反复调用的核心句型/表达
- 真实打卡数据出现后，优先按真实错因替换本清单中的低价值条目
- 若后续新增 TSV 条目与本清单高度近义，默认先比较是否值得替换，而不是并存

---

## A. 写作高优先级句型（首轮 10 条）

1. It is widely acknowledged that consistent practice is essential to language learning.
2. From my perspective, effective learning requires both effort and reflection.
3. One of the main reasons is that good habits improve both speed and quality.
4. More importantly, a clear plan helps us use limited time wisely.
5. Only by taking action can we turn goals into real progress.
6. It is not enough to understand a point once; we must review it repeatedly.
7. Compared with passive input, active output leaves a deeper impression.
8. A practical method is to divide a large task into several small steps.
9. Instead of waiting for motivation, we should rely on discipline.
10. Regular self-correction helps us write more clearly and naturally.

### 保留理由

- 覆盖 CET-6 写作里最常用的观点句、原因句、强调句、倒装句、对比句
- 与“30 分钟 / 严格监督 / 弱项优先”当前主线高度一致
- 既能直接背诵迁移，也适合做改写、翻译回译和自改训练

---

## B. 翻译高优先级句对（首轮 10 条）

1. 坚持不是一时冲动，而是长期选择。 → Persistence is a long-term choice, not a momentary impulse.
2. 时间管理决定你能走多远。 → Time management shapes how far you can go.
3. 有效的学习依赖重复和反思。 → Effective learning depends on repetition and reflection.
4. 清晰的目标会让努力更聚焦。 → A clear goal makes effort more focused.
5. 及时复盘错误能提高学习效率。 → Reviewing mistakes in time can improve learning efficiency.
6. 正确的方法能让有限时间更高效。 → The right method can make limited time more productive.
7. 持续输入和稳定输出同样重要。 → Consistent input and stable output are equally important.
8. 与其等有动力再开始，不如先按计划行动。 → Instead of waiting for motivation, it is better to act according to the plan first.
9. 把大任务拆成几个小步骤，会更容易坚持下去。 → Dividing a large task into several small steps makes it easier to keep going.
10. 如果忽视弱项，进步就会一直很慢。 → If we ignore weak points, improvement will remain slow.

### 保留理由

- 覆盖“不是……而是…… / 与其……不如…… / 越早……越快…… / 即使……也……”等高频结构周边语感
- 更贴近用户当前的学习情境，适合作为翻译与写作互相回收的桥梁素材
- 中英文都足够自然，适合做严格纠错型训练

---

## C. 高频监督表达（首轮 8 条）

1. in the long run
2. keep track of
3. focus on
4. play a crucial role in
5. make full use of
6. turn goals into real progress
7. rely on discipline
8. review mistakes in time

### 保留理由

- 可直接服务“计划—执行—复盘”三段式反馈
- 既能做输入识别，也能做输出复用
- 与当前 Discord 严格监督型口径一致，不是纯装饰表达

---

## 低优先级处理口径（当前先不删）

以下类型先不作为优先轮换层，但暂时保留在 TSV 中：
- 语义和高优先级句型高度重合、只是轻微措辞变化的条目
- 更适合作为阅读理解输入、但不适合作为输出骨架的句子
- 暂时还没有在题包、评分反馈或弱项追踪中体现出高复用价值的条目

等首轮真实打卡数据出现后，再决定是否：
1. 替换本清单中的低价值条目
2. 把低频条目下沉为备用层
3. 对高度重复条目做真正去重

---

## 下一步

1. 后续若继续补 `input/`，先优先比较是否能进入本清单，而不是只往 TSV 追加
2. 等真实打卡数据出现后，按真实错因给本清单重排优先级
3. 等首个真实听力样本核验成功后，再补一版“听力高优先级同义替换轮换清单”
