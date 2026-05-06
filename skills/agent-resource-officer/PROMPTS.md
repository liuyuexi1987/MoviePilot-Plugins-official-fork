# AgentResourceOfficer Prompt Examples

## Startup

```text
使用 agent-resource-officer skill，先调用 auto，自动读取 startup 和推荐 request_templates。
```

## Low Token Auto

```text
使用 agent-resource-officer skill，先调用 auto --summary-only，只返回自动启动流的最小决策摘要。
```

## Decide

```text
使用 agent-resource-officer skill，先调用 decide --summary-only，告诉我现在应该继续旧会话还是按推荐 recipe 开始新流程。
```

## Command Only Decide

```text
使用 agent-resource-officer skill，调用 decide --command-only，只返回下一步 helper 命令。
```

## Confirmed Command

```text
使用 agent-resource-officer skill，在我已经确认执行后，调用 decide --command-only --confirmed，只返回执行用 helper 命令。
```

## Manual Startup

```text
使用 agent-resource-officer skill，先调用 startup，读取 recommended_request_templates，然后按推荐 recipe 获取低 token 请求模板。
```

## PanSou Search

```text
使用 agent-resource-officer skill，盘搜搜索“大君夫人”，分别展示 115 和夸克结果，让我选择编号。不要直接转存，等我确认编号。
```

## Generic Search

```text
使用 agent-resource-officer skill，搜索“大君夫人”。注意：普通“搜索/找片”默认先走盘搜，不要先脑补成影巢候选或 MP 搜索。
```

```text
使用 agent-resource-officer skill，执行普通“搜索/找片”后，优先原样转述 route 返回的条目列表。不要把结果二次改写成“资源状态 / 推荐清单 / 要现在下载吗”这类摘要；不要额外补“费用、评分、推荐星级”表述。只保留资源官已经给出的编号、网盘、来源、提取码、摘要、链接和下一步提示。
```

## Cloud Search

```text
使用 agent-resource-officer skill，云盘搜索“蜘蛛侠”。这条入口只比较盘搜和影巢，不进入 MP/PT。
```

```text
使用 agent-resource-officer skill，执行“云盘搜索 大君夫人”时，必须直接调用 route "云盘搜索 大君夫人"。不要偷换成“盘搜搜索 大君夫人”，不要先自己做网页搜索，也不要先把结果加工成“推荐资源/分析结论”。优先原样展示插件返回的 `盘搜结果` 和 `影巢结果` 两段、原始编号、原始链接和下一步提示。
```

```text
使用 agent-resource-officer skill，执行“云盘搜索 大君夫人”后，不要把返回改写成自己的表格摘要，不要把 115 和夸克各自重新从 1 开始编号，也不要只摘“亮点”。如果插件返回了全局编号和 `影巢结果` 段落，就原样保留；如果插件提示“影巢候选未自动展开”，也原样保留这句。
```

```text
使用 agent-resource-officer skill，夸克转存失败后，如果插件只返回“夸克转存失败：无法转存到 /飞书”，不要自行追加“默认转存目录不存在”“换 path=/ 试试”这类路径猜测。除非插件明确指出路径问题，否则只说明“原因未明，先不要擅自推断路径问题”。
```

## Update Check

```text
使用 agent-resource-officer skill，更新检查“大君夫人”。这条入口必须先直接调用 route "更新检查 大君夫人"，不要先清空会话，不要先网页搜索，不要先走影巢候选。先把官方参考进度、盘搜最新集资源、影巢最新集资源原样展示给我，再让我自己选编号。
```

```text
使用 agent-resource-officer skill，刷新影巢Cookie。不要 route 这句话，直接运行 hdhive-cookie-refresh，把本机浏览器里的 hdhive.com 完整 Cookie 写回 MoviePilot 和 AgentResourceOfficer。
```

```text
使用 agent-resource-officer skill，修复影巢签到。不要 route 这句话，直接运行 hdhive-checkin-repair：先从本机浏览器刷新影巢 Cookie，再自动重试一次影巢签到，并把最终结果回给我。
```

```text
使用 agent-resource-officer skill，刷新夸克Cookie。不要 route 这句话，直接运行 quark-cookie-refresh，把本机浏览器里的 pan.quark.cn 完整 Cookie 写回 MoviePilot 和 AgentResourceOfficer。
```

```text
使用 agent-resource-officer skill，修复夸克转存。如果刚才的失败明确是登录态问题，直接运行 quark-transfer-repair；如果你还保留着刚才失败的原始命令（例如“选择 7”或“夸克转存 21世纪大君夫人”），优先运行 quark-transfer-repair --retry-text "<原命令>"，刷新完 Cookie 后自动再试一次。
```

```text
使用 agent-resource-officer skill，执行“检查 大君夫人”时，把它当成“更新检查 大君夫人”的简写。不要把它当成普通搜索，也不要走影巢候选。
```

```text
使用 agent-resource-officer skill，执行“更新 大君夫人”时，先把它等价成“更新检查 大君夫人”。如果返回里已经列出盘搜/影巢最新集资源，不要再改写成“你要更新的是不是选项1”。只有在更新检查明确要求继续 PT 搜索时，才提示我是否执行 PT搜索。
```

```text
使用 agent-resource-officer skill，处理普通“搜索/找片/更新检查”时，不要先调用 `session-clear default`。只有用户明确要求“清空会话/重置会话”时，才允许先清会话。
```

```text
使用 agent-resource-officer skill，如果“影巢签到”或“影巢签到日志”明确提示网页登录态失效、Cookie 失效、require login 或自动登录拿不到有效 Cookie，先提醒我确认已在 Edge 登录 https://hdhive.com，然后自动执行 hdhive-checkin-repair，再把新的签到结果发给我。不要先让我手工复制 Cookie。
```

```text
使用 agent-resource-officer skill，如果夸克转存失败里明确出现“require login [guest]”“夸克登录态已过期”“当前夸克登录态不足”，先提醒我确认已在 Edge 登录 https://pan.quark.cn，然后自动执行 quark-transfer-repair；如果能拿到刚才失败的原始转存命令，就带上 --retry-text 直接重试一次。不要对 41031、分享受限、分享者封禁这类错误误触发 Cookie 修复。
```

```text
使用 agent-resource-officer skill，执行“清空夸克默认转存目录”或“清空夸克默认目录”时，直接原样透传给 route。不要改写成 115 清理，不要先做搜索，不要先做更新检查。
不要先 grep `aro_request.py` 或自己判断 helper 是否“内置支持”这个命令；这类清空命令本来就是通过 `route "<原话>"` 进入插件路由，不是 helper 的独立子命令。
```

```text
使用 agent-resource-officer skill，执行“清空115转存目录”“清空115默认转存目录”或“清空115默认目录”时，直接原样透传给 route。不要改写成夸克清理，不要先做搜索，不要先做更新检查。
不要先 grep `aro_request.py` 或自己判断 helper 是否“内置支持”这个命令；这类清空命令本来就是通过 `route "<原话>"` 进入插件路由，不是 helper 的独立子命令。
```

```text
使用 agent-resource-officer skill，返回盘搜/影巢/更新检查的资源列表时，必须保留插件原始编号。不要把 `7/8/9/14` 这类编号改写成无编号段落，也不要只在总结里提编号。用户后续需要直接回复编号执行。
```

## PT Search

```text
使用 agent-resource-officer skill，PT搜索“蜘蛛侠”。这条入口等同于 MP搜索，走 MoviePilot 原生 PT 搜索和评分。
```

## HDHive Search

```text
使用 agent-resource-officer skill，影巢搜索“蜘蛛侠”。如果有多个候选影片，先让我选择影片；再展示资源列表。
```

## Direct Share Link

```text
使用 agent-resource-officer skill，处理这个分享链接并转存到默认目录：https://pan.quark.cn/s/xxxx
```

## Custom Path

```text
使用 agent-resource-officer skill，把这个夸克链接转存到 /飞书：链接 https://pan.quark.cn/s/xxxx path=/飞书
```

## Continue Choice

```text
使用 agent-resource-officer skill，继续当前会话，选择 1。如果返回 confirmation_message，先给我确认提示。
```

## Health Check

```text
使用 agent-resource-officer skill，执行 selfcheck，确认 AgentResourceOfficer 协议和请求模板都正常。
```

## Local Selftest

```text
使用 agent-resource-officer skill，先运行 selftest，验证本地 helper 的命令生成逻辑。
```

## Command Catalog

```text
使用 agent-resource-officer skill，运行 commands，查看 helper 支持的命令、联网需求和写入风险。
```

## Helper Version

```text
使用 agent-resource-officer skill，运行 version，确认当前 helper 版本。
```

## Config Check

```text
使用 agent-resource-officer skill，运行 config-check，确认连接配置存在，但不要输出 API Key。
```

## External Agent

```text
你是 MoviePilot Agent影视助手的外部智能体入口。不要直接调用影巢、115、夸克、盘搜底层 API；所有搜索、选择、转存、115 状态都只调用 AgentResourceOfficer。每个用户或群聊固定使用 session=agent:会话ID。新会话先 startup；用户发搜索/链接时调用 route；用户发选择/详情/下一页时调用 pick。不要输出 API Key、Cookie、Token。
展示资源列表时，不要压缩掉关键字段：网盘、解锁分、大小、清晰度、来源、集数/更新信息、字幕、详情摘要都要尽量保留。
用户只说“搜索/找 某片”时，先原样透传给 route，不要擅自续跑旧 session，也不要先脑补成影巢候选选择。默认搜索应先走盘搜；只有用户明确说“影巢搜索”才进影巢，明确说“MP搜索/PT搜索”才进 MP/PT。
用户只说“更新/查更新 某片”时，先原样透传给 route，并优先走“更新检查 某片”；不要先清空会话，不要先影巢候选，不要先网页搜索。更新检查的职责是直接列出官方参考进度、盘搜最新集资源、影巢最新集资源，让用户自己判断和选择编号。
```

## External Agent Helper

```text
使用 agent-resource-officer skill，运行 external-agent，输出可交给 WorkBuddy、Hermes、OpenClaw（小龙虾）、微信侧智能体或其他外部智能体的紧凑提示词和最小工具约定。需要完整说明时运行 external-agent --full。
```

## Ask Another Agent To Create Skill

```text
请阅读 https://github.com/liuyuexi1987/MoviePilot-Plugins ，重点阅读 docs/AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md、skills/agent-resource-officer/SKILL.md、skills/agent-resource-officer/EXTERNAL_AGENTS.md。然后在你的环境里创建或安装 agent-resource-officer Skill。Skill 里只固化通用流程、工具调用方式、session 规则和错误处理，不要写入 API Key、Cookie、Token。创建后请用 external-agent 输出接入信息，并自测：用户说“盘搜搜索 大君夫人”时走 route；用户再说“选择 3”时沿用同一个 agent:会话ID 走 pick。
```

## Readiness

```text
使用 agent-resource-officer skill，运行 readiness，确认配置、本地 helper 和 MoviePilot 插件接口都可用。
```

## Doctor

```text
使用 agent-resource-officer skill，先调用 doctor，给我一个只读的启动/健康/会话/恢复总览，再决定是否继续旧会话。
```

## Low Token Doctor

```text
使用 agent-resource-officer skill，先调用 doctor --summary-only，只返回最省 token 的决策摘要和下一步命令建议。
```

## Recovery

```text
使用 agent-resource-officer skill，先调用 sessions 和 recover，告诉我当前最值得继续的会话；如果需要继续执行，先展示 confirmation_message。
```

## Low Token Recovery

```text
使用 agent-resource-officer skill，先调用 recover --summary-only，只返回恢复决策摘要和下一步命令建议。
```

## Plan Audit

```text
使用 agent-resource-officer skill，先看最近 plans 和 history，不要默认只看 default 会话；如果发现未执行计划，再告诉我是否值得继续。
```

## Execute Exact Plan

```text
使用 agent-resource-officer skill，精确执行这个 dry-run 计划：plan-execute --plan-id plan-xxx。执行前先确认这是我要的 plan_id。
```

## Clear Exact Plan

```text
使用 agent-resource-officer skill，清理这个已确认不需要的 dry-run 计划：plans-clear --plan-id plan-xxx。不要批量清理其他计划。
```
