# 外部智能体接入 Agent影视助手

目标：给 WorkBuddy、Hermes、OpenClaw（小龙虾）、微信侧智能体或其他外部智能体一套统一接入范式。`Agent影视助手 / AgentResourceOfficer` 负责服务端能力执行；外部智能体只做客户端理解、调度和展示，115 云盘、夸克云盘等云盘资源搜索、解锁、转存、115 登录状态全部交给插件完成。

公开仓库地址：

```text
https://github.com/liuyuexi1987/MoviePilot-Plugins
```

## 当前接入状态

- 当前插件版本：`Agent影视助手 0.2.68`
- 当前 helper 版本：`agent-resource-officer 0.1.42`
- 当前最小循环：`startup -> decide --summary-only -> route --summary-only -> followup --summary-only`
- 当前优先读取字段：`recommended_agent_behavior`、`auto_run_command`、`confirm_command`、`display_command`
- 当前 AI 识别失败诊断入口：
  - `route "失败样本 <片名>" --summary-only`
  - `route "工作清单 <片名>" --summary-only`
  - `route "样本洞察 <片名>" --summary-only`
  - `route "重放样本 3" --summary-only`
  - `route "重放 3" --summary-only`
  - `route "确认" --summary-only`
  - `templates --recipe ai_reingest --compact`

给其他机器或其他智能体复现时，优先让它阅读这三个文件：

- `docs/AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md`
- `skills/agent-resource-officer/SKILL.md`
- `skills/agent-resource-officer/EXTERNAL_AGENTS.md`

## 当前推荐口令

推荐外部智能体优先使用这些固定入口，不要自己发明同义句：

- 搜索：
  - `搜索 <片名>` / `找 <片名>`
  - `盘搜搜索 <片名>`
  - `影巢搜索 <片名>`
  - `云盘搜索 <片名>`
  - `MP搜索 <片名>` / `PT搜索 <片名>`
- 执行：
  - `转存 <片名>`：默认等同 `115转存 <片名>`
  - `夸克转存 <片名>`
  - `115转存 <片名>`
  - `下载 <片名>`
- 更新：
  - `更新检查 <片名>`
  - `检查 <片名>`
- 维护：
  - `清空115转存目录`
  - `清空夸克转存目录`
  - `影巢签到`
  - `影巢签到日志`
  - `刷新影巢Cookie`
  - `修复影巢签到`
  - `刷新夸克Cookie`
  - `修复夸克转存`

## 高概率踩坑

- `云盘搜索` 不是 `盘搜搜索` 的别名。
  - 必须原样 route。
  - 目标是一起看盘搜 + 影巢，而不是先盘搜后自己总结。
- 不要自己重排编号。
  - 资源官返回 `1..16`、`#17..#24` 时，要原样保留。
  - 不要按“115 一组、夸克一组、影巢一组”各自从 1 重排。
- 不要把插件结果加工成“推荐资源 / 分析结论 / 现在要不要转存”。
  - 这会破坏后续按编号继续执行。
- `更新` 类请求不要先 `session-clear`，不要先影巢候选，优先直接 route 到 `更新检查`。
- 夸克失败不要随意猜成路径问题。
  - 如果插件只返回 `夸克转存失败：无法转存到 /飞书`，原因就是未明，不要自己补“默认目录不存在”“换 path=/ 试试”。
- 只有明确登录态报错时，才触发 Cookie 修复。
  - 夸克：`require login [guest]`、`夸克登录态已过期`、`当前夸克登录态不足`
  - 影巢：网页登录态失效、自动登录拿不到有效 Cookie
  - `41031`、分享封禁、分享受限都不属于 Cookie 失效。
- 影巢签到恢复不要教用户手工找 Cookie。
  - 当前标准恢复方式是本机导出工具自动写回。
- 长线程跑久后，智能体可能被旧上下文压缩污染。
  - 表现：`15详情` 被改写成 `选择 15`、编号续接到旧结果、一直套用旧展示格式。
  - 处理：先清当前 ARO session 和计划，再让智能体重新读取 Skill。
  - 不要在普通 `搜索 / 更新检查 / 检查` 前主动清会话，否则会破坏正常编号续接。

## 接入原则

- 不让外部智能体直接调用影巢、115、夸克、盘搜底层 API。
- 不把 Cookie、Token、API Key 写进提示词正文。
- 所有调用都走 `AgentResourceOfficer` 的标准 `assistant` 接口。
- 同一个用户或群聊固定使用同一个 `session`，例如 `agent:${chat_id}`。
- 搜索和展示是读操作；选择编号、转存、解锁、执行计划是写操作，需要用户明确输入编号或链接。
- 首次接入建议先读取 `assistant/preferences`。如果未初始化，先询问用户片源偏好，再保存为偏好画像。
- 云盘资源和 PT 资源分开评分：云盘看清晰度、字幕、完整度、网盘类型和影巢积分；PT 看做种数、免费/促销、下载折算、清晰度、字幕和匹配度。
- 如果 helper 的 `summary-only` 返回 `recommended_agent_behavior=auto_continue` 或 `auto_continue_then_wait_confirmation`，可以直接执行 `auto_run_command`；其他结果先停下来展示或确认。

推荐把外部智能体自身的执行分支固定成 5 类：

- `auto_continue`
- `auto_continue_then_wait_confirmation`
- `wait_user_confirmation`
- `show_only`
- `stop`

不要在接入层再定义第三套状态机，直接复用 helper 返回值。

推荐的最小接入循环：

1. 调 `startup`
2. 调 `decide --summary-only`
3. 用户发自然语言后，调 `route --summary-only`
4. 读取 `recommended_agent_behavior`
5. 如果执行过计划，再调 `followup --summary-only`

## 长线程维护

如果外部智能体接的是微信、飞书、WorkBuddy、Claw 这类长时间不断开的线程，建议把“会话清理”当作维护动作，而不是日常前置步骤。

适合清理的情况：

- 长时间测试后，智能体开始误解固定命令
- `编号 + 详情` 被当成直接执行
- 当前编号明显续接到了很久以前的搜索结果
- 智能体反复沿用旧提示词、旧展示格式或旧推荐规则

清理 ARO 当前会话：

```bash
python3 scripts/aro_request.py session-clear --session default
python3 scripts/aro_request.py plans-clear --session default
```

如果接入层给每个用户或群聊分配了固定 session，例如 `agent:wechat-room-1`，就把 `default` 换成实际 session：

```bash
python3 scripts/aro_request.py session-clear --session agent:wechat-room-1
python3 scripts/aro_request.py plans-clear --session agent:wechat-room-1
```

清理后建议让外部智能体重新读取：

```text
skills/agent-resource-officer/SKILL.md
docs/AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md
```

如果客户端本身还有 memory / thread memory / project memory，也可以只清和资源工作流相关的旧记忆。不要删除 API Key、Cookie、helper 配置和 skill 文件。

可以发给外部智能体的短提示：

```text
忽略本线程之前的资源搜索上下文，重新读取 agent-resource-officer skill 和当前 memory；后续资源命令按最新规则执行。编号详情请求必须保留详情意图，例如“15详情”只能按“选择 15 详情”处理，不能改成“选择 15”。
```

如果场景是“只给片名，让智能体自己比较多个来源”，优先使用统一搜索决策入口：

- `route "智能搜索 <片名>" --summary-only`
- `route "资源决策 <片名>" --summary-only`
- 如果是 MP 推荐列表续接，也支持直接发：
  - `route "选择 1 决策" --summary-only`
  - `route "选择 1 计划" --summary-only`
  - `route "选择 1 确认" --summary-only`
  - `route "详情 1" --summary-only`
  - 也支持单句直达当前榜单首项：
    - `route "智能发现 热门电影 详情" --summary-only`
    - `route "智能发现 热门电影 计划" --summary-only`
    - `route "智能发现 热门电影 确认" --summary-only`
  - 也支持单句直达具体来源：
    - `route "智能发现 热门电影 盘搜" --summary-only`
    - `route "智能发现 热门电影 影巢" --summary-only`
    - `route "智能发现 热门电影 原生" --summary-only`
  - 如果已经切到 `盘搜 / 影巢 / 原生`，也支持：
    - `route "回推荐" --summary-only`
    - `route "盘搜" --summary-only`
    - `route "影巢" --summary-only`
    - `route "原生" --summary-only`
  - 在 `盘搜 / 原生` handoff 会话里，也支持：
    - `route "详情" --summary-only`
    - `route "计划" --summary-only`
    - `route "确认" --summary-only`
    - `route "决策" --summary-only`
  - 也支持直接对当前榜单首项继续发：
    - `route "详情" --summary-only`
    - `route "计划" --summary-only`
    - `route "确认" --summary-only`
  - 进入推荐会话后，也支持：
    - `route "决策 1" --summary-only`
    - `route "计划 1" --summary-only`
    - `route "确认 1" --summary-only`
    - 如果先看了 `详情 1`，还可以直接发：
    - `route "详情" --summary-only`
    - `route "决策" --summary-only`
    - `route "计划" --summary-only`
    - `route "确认" --summary-only`
    - `route "盘搜" --summary-only`
    - `route "影巢" --summary-only`
    - `route "原生" --summary-only`
    - `route "电影" --summary-only`
    - `route "电视剧" --summary-only`
    - `route "豆瓣" --summary-only`
    - `route "热映" --summary-only`
    - `route "番剧" --summary-only`
- 如果用户已经明确要计划或直接执行，也可以直接发：
  - `route "资源决策 <片名> 详情" --summary-only`
  - `route "资源决策 <片名> 计划" --summary-only`
  - `route "资源决策 <片名> 确认" --summary-only`
  - `route "资源决策 <片名> 直接执行" --summary-only`
- 如果已经进入同一资源决策会话，还可以直接发：
  - `route "先计划" --summary-only`
  - `route "确认执行" --summary-only`
  - `route "先看详情" --summary-only`
  - 也支持更短的会话内命令：`计划`、`详情`、`确认`
- 或者先读模板：`templates --recipe smart_search --compact`
- 或先读模板：`templates --recipe smart_decision --compact`
- 如果希望一步拿到待确认计划，用：`route "智能计划 <片名>" --summary-only`
- 或先读模板：`templates --recipe smart_search_plan --compact`
- 如果用户已经明确要求立即执行，用：`route "智能执行 <片名>" --summary-only`
- 或先读模板：`templates --recipe smart_search_execute --compact`

这条入口会统一按 `盘搜 -> 影巢 -> MP/PT` 搜索，并自动读取当前会话偏好中的：

- 可用源：`enable_pansou / enable_hdhive / enable_mp_pt`
- 可用云盘：`has_115 / has_quark`

所以如果用户提前说明“只有夸克”“没有 115”“不用盘搜”“只用 MP/PT”，外部智能体无需自己再维护一套分支判断，直接先保存偏好，再调用 `智能搜索` 即可。

如果已经跑过一次 `智能搜索`，还可以在同一 session 里直接发：

- `计划最佳`
- `执行最佳`
- `换影巢`
- `换盘搜`
- `换PT`
- `保守一点`
- `激进一点`
- `只用夸克`
- `只用115`
- `只走PT`
- `不用影巢`
- `按保存偏好`

这会按当前首选自动生成待确认 `plan_id`，但仍然需要后续 `执行计划` 才会真正写入。
而 `执行最佳` / `智能执行` 会直接走写入链，只适用于用户已经明确要求立即执行的场景。

如果当前问题是“整理为什么失败、有没有 AI 失败样本可以继续分析”，优先走只读链：

- `route "本地诊断 <片名>" --summary-only`
- `route "失败样本 <片名>" --summary-only`
- `route "工作清单 <片名>" --summary-only`
- `route "样本洞察 <片名>" --summary-only`
- 或先读模板：`templates --recipe ai_reingest --compact`

如果用户已经明确要对某条样本做二次识别重放，再用：

- `route "重放样本 3" --summary-only`
- 或在当前 AI 样本会话里直接发：`route "重放 3" --summary-only`
- 计划生成后再发：`route "确认" --summary-only`
- 重放后可直接发：`route "诊断" --summary-only`、`route "入库状态" --summary-only`

这一步仍然遵守确认链：先生成待确认计划，再通过 `确认` 或 `执行计划 <plan_id>` 实际执行。

三类入口都复用这一套 assistant 协议：

- 外部智能体：优先用 Skill/helper，按 `startup -> decide -> route -> followup` 跑。
- MP 内置智能体：优先用 Agent Tool / `request_templates`，不要让模型自己拼底层 API。
- 飞书入口：把消息送进插件内置 Channel，底层仍然走 `route / pick / followup`。

最低 token 接入时，优先读取 `assistant/request_templates` 返回里的：

- `orchestration_contract`
- `entry_patterns`
- `entry_playbooks`
- `recommended_recipe_detail`

## 必要配置

把下面两个变量配置到外部智能体的安全变量区或工具配置区：

```text
BASE_URL=https://你的 MoviePilot 可访问地址
MP_API_TOKEN=你的 MoviePilot API_TOKEN
```

`BASE_URL` 按实际部署填写：

```text
同机调用示例：BASE_URL=http://127.0.0.1:3000
局域网调用示例：BASE_URL=http://你的局域网IP:3000
公网反代示例：BASE_URL=https://你的 MoviePilot 域名
```

不要把 `MP_API_TOKEN` 写进提示词正文，只放在外部智能体的安全变量、工具密钥或私有配置里。

如果 `MoviePilot` 不在当前机器，而是在 NAS、Windows 或另一台 Docker 主机，请同时阅读：

- `docs/AGENT_RESOURCE_OFFICER_REMOTE_DEPLOY.md`

跨机器时，外部智能体的用法不变，主要变化只是 `BASE_URL` 和旁路服务地址的可达性配置。

如果你只想最低成本接入，不要先读完整说明，先执行：

```bash
python3 <SKILL_HOME>/agent-resource-officer/scripts/aro_request.py readiness
python3 <SKILL_HOME>/agent-resource-officer/scripts/aro_request.py external-agent
```

然后按 `external-agent` 输出里的 `execution_policy_contract`、`execution_loop_contract`、`entry_playbooks` 和 `deprecated_aliases` 接入。

## 从仓库复现 Skill

在需要接入的机器上：

```bash
git clone https://github.com/liuyuexi1987/MoviePilot-Plugins.git
cd MoviePilot-Plugins
bash skills/agent-resource-officer/install.sh --dry-run
bash skills/agent-resource-officer/install.sh
```

仓库已经包含本机浏览器 Cookie 导出工具，不需要另外下载用户本机的旧双击工具：

```text
tools/hdhive-cookie-export
tools/quark-cookie-export
```

执行 `install.sh` 后，这两个工具会一起复制到 skill 目录的 `tools/` 下。helper 会优先查找：

```text
skills/agent-resource-officer/tools/hdhive-cookie-export
skills/agent-resource-officer/tools/quark-cookie-export
```

所以安装后可以直接用智能体命令调用 `刷新影巢Cookie`、`修复影巢签到`、`刷新夸克Cookie`、`修复夸克转存`。只有部署者明确指定自定义路径时，才需要配置 `ARO_HDHIVE_COOKIE_EXPORT_DIR` 或 `ARO_QUARK_COOKIE_EXPORT_DIR`。

然后创建连接配置：

```bash
mkdir -p ~/.config/agent-resource-officer
cat > ~/.config/agent-resource-officer/config <<'EOF'
ARO_BASE_URL=https://你的 MoviePilot 可访问地址
ARO_API_KEY=你的 MoviePilot API_TOKEN
EOF
```

验证：

```bash
python3 <SKILL_HOME>/agent-resource-officer/scripts/aro_request.py readiness
python3 <SKILL_HOME>/agent-resource-officer/scripts/aro_request.py external-agent
```

## 快速生成提示词

如果已经安装仓库里的 `agent-resource-officer` Skill，可以直接让 helper 输出可复制的提示词和最小工具约定：

```bash
python3 <SKILL_HOME>/agent-resource-officer/scripts/aro_request.py external-agent
python3 <SKILL_HOME>/agent-resource-officer/scripts/aro_request.py external-agent --full
```

这里的 `<SKILL_HOME>` 指你的智能体 Skill 根目录，例如某些客户端会使用自己的 `skills/` 目录；不要把个人机器路径写进公开 Skill。

`external-agent` 输出紧凑 JSON，适合直接喂给外部智能体；`external-agent --full` 输出完整说明。旧命令 `workbuddy` 仍保留为兼容别名，但已标记为 deprecated。

## 让外部智能体创建自己的 Skill

如果外部智能体支持 Skill、项目能力或本地工具目录，推荐让它读完仓库后先创建或安装自己的 `agent-resource-officer` Skill。这样比只发普通聊天提示更稳，换会话后也不容易失去操作记忆。

可以直接给外部智能体这段任务：

```text
请阅读 https://github.com/liuyuexi1987/MoviePilot-Plugins ，重点阅读 docs/AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md、skills/agent-resource-officer/SKILL.md、skills/agent-resource-officer/EXTERNAL_AGENTS.md。然后在你的环境里创建或安装 agent-resource-officer Skill，用于调用 MoviePilot Agent影视助手。

要求：
1. 只把通用流程、工具调用方式、会话规则和错误处理写进 Skill。
2. 不要把 API Key、Cookie、Token、个人路径写进 Skill。
3. 所有资源搜索、影巢解锁、115/夸克转存、115 登录状态都必须调用 Agent影视助手。
4. 不要直接调用影巢、盘搜、115、夸克底层 API。
5. Skill 至少包含 startup、route、pick 三个核心入口。
6. 增加 preferences 入口。第一次接入用户时先读取偏好，未初始化就询问并保存。
7. 同一个用户或群聊固定使用 session=agent:会话ID。
8. 搜索结果只展示 Agent影视助手返回的内容，编号选择继续调用 pick。
9. 写入类动作必须等用户明确选择编号或给出链接后再执行；下载、订阅、影巢解锁和网盘转存优先生成 plan_id。
10. 创建后请运行 external-agent 或等价自检，确认 schema_version=external_agent.v1。
11. 资源流命令直接走 agent-resource-officer 的 route/pick，不要先走 MCP、tool_search、curl 或 raw API。资源流包括：云盘搜索、盘搜、影巢、MP搜索、PT搜索、转存、夸克转存、115转存、下载、更新、更新检查、检查、选择、详情、n、下一页和编号续选。
12. route/pick 默认输出就是适合聊天展示的纯文本 message，优先原样转发，不要重新改写资源列表；只有需要程序化读取字段时才加 --json-output。
13. 如果原始输出里有“智能建议”，必须保留；如果没有，也可以在原始列表后追加智能建议。智能建议不限制长短，但必须引用原始编号，不能替代列表、不能重新编号。
```

创建完成后，用这两句检查它是否真正理解：

```text
如果我说“盘搜搜索 大君夫人”，你会调用哪个入口？
如果我再说“选择 3”，你会如何沿用 session 继续？
```

合格回答应该是：先用 `route` 处理搜索，再用同一个 `agent:会话ID` 调用 `pick` 继续编号选择。

## 最小工具

### route

```json
{
  "name": "agent_resource_route",
  "method": "POST",
  "url": "{BASE_URL}/api/v1/plugin/AgentResourceOfficer/assistant/route?apikey={MP_API_TOKEN}",
  "body": {
    "text": "{{text}}",
    "session": "{{session}}",
    "compact": true
  }
}
```

### pick

```json
{
  "name": "agent_resource_pick",
  "method": "POST",
  "url": "{BASE_URL}/api/v1/plugin/AgentResourceOfficer/assistant/pick?apikey={MP_API_TOKEN}",
  "body": {
    "choice": "{{choice}}",
    "action": "{{action}}",
    "session": "{{session}}",
    "compact": true
  }
}
```

### startup

```json
{
  "name": "agent_resource_startup",
  "method": "GET",
  "url": "{BASE_URL}/api/v1/plugin/AgentResourceOfficer/assistant/startup?apikey={MP_API_TOKEN}"
}
```

### request_templates

```json
{
  "name": "agent_resource_request_templates",
  "method": "POST",
  "url": "{BASE_URL}/api/v1/plugin/AgentResourceOfficer/assistant/request_templates?apikey={MP_API_TOKEN}",
  "body": {
    "recipe": "external_agent",
    "include_templates": false
  }
}
```

## 外部智能体系统提示词

```text
你是 MoviePilot Agent影视助手的外部智能体入口。

核心原则：
1. 不直接调用影巢、115、夸克、盘搜底层 API。
2. 所有资源搜索、选择、转存、115 登录状态，都只调用 AgentResourceOfficer。
3. 不输出 API Key、Cookie、Token。
4. 遇到编号选择、详情、下一页，要沿用同一个 session。
5. 写入类动作，例如转存、解锁、执行计划，除非用户已经明确选择编号或给出链接，否则不要擅自执行。

每次新会话先调用 startup。需要低 token 调用说明时，调用 request_templates，recipe=external_agent。

统一入口：
POST /api/v1/plugin/AgentResourceOfficer/assistant/route?apikey={MP_API_TOKEN}

请求体：
{
  "text": "用户原始指令",
  "session": "agent:用户或会话ID",
  "compact": true
}

编号选择入口：
POST /api/v1/plugin/AgentResourceOfficer/assistant/pick?apikey={MP_API_TOKEN}

请求体：
{
  "choice": 1,
  "session": "agent:用户或会话ID",
  "compact": true
}

详情、审查、下一页入口：
POST /api/v1/plugin/AgentResourceOfficer/assistant/pick?apikey={MP_API_TOKEN}

请求体：
{
  "action": "详情",
  "session": "agent:用户或会话ID",
  "compact": true
}

常用用户指令：
- MP搜索 蜘蛛侠
- 搜索 蜘蛛侠
- 盘搜搜索 大君夫人
- ps大君夫人
- 1大君夫人
- 影巢搜索 蜘蛛侠
- yc蜘蛛侠
- 2蜘蛛侠
- 选择 1
- 详情
- 审查
- 下一页
- 115状态
- 115登录
- 检查115登录
- 链接 https://pan.quark.cn/s/xxxx path=/飞书
- 链接 https://115cdn.com/s/xxxx path=/待整理

默认目录：
- 115 默认转存到 /待整理
- 夸克默认转存到 /飞书
- 用户显式写 path=/目录 或 位置=目录 时，以用户指定目录为准

展示规则：
1. 只展示 AgentResourceOfficer 返回的 message，不自己编造资源。
2. 如果返回候选影片或 MP/TMDB 候选，先让用户选影片编号，不要替用户默认选第一项。
3. 如果返回资源列表，保留每条资源的网盘、解锁分、大小、清晰度、来源、集数/更新信息、字幕和详情摘要，提示用户回复“选择 编号”。
4. 如果返回转存结果，只总结成功/失败和目录。
5. 如果返回需要扫码登录，展示二维码或提示用户完成扫码，再调用“检查115登录”。
6. 如果返回更新检查结果，保留 `🟨 盘搜结果`、`🟦 影巢结果`、`🗄 #编号`、`📺 #编号`、`🕒日期`、`📌 集数` 这些原始行，不要改写成 `#: 来源 / 详情 / 日期` 字段表。

错误处理：
1. 如果接口失败，先调用 selfcheck 或 startup。
2. 如果 session 丢失，让用户重新发搜索词或链接。
3. 如果 115 不可用，引导用户发“115登录”。
4. 如果夸克失败，提示可能 Cookie 失效，让用户更新夸克登录状态。
5. 不要让用户提供 Cookie、Token、API Key 到聊天里。

最省 token 流程：
1. 每个新会话先 startup 一次。
2. 用户发搜索/链接时只调用 route。
3. 用户发选择/详情/下一页时只调用 pick。
4. 不解析长文本，不重复请求底层服务。
```

## 推荐测试

```text
115状态
MP搜索 蜘蛛侠
1大君夫人
2蜘蛛侠
链接 https://pan.quark.cn/s/xxxx path=/飞书
```
