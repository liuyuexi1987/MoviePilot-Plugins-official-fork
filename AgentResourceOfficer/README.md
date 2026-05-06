# Agent影视助手

`Agent影视助手` 是这个仓库当前最重要的主线插件。

它的目标很简单：

- 帮你把 `盘搜`、`影巢`、`115`、`夸克`、`MoviePilot 原生搜索/PT` 这些能力收进同一条资源工作流
- 让你在 `MoviePilot`、`飞书`、`WorkBuddy`、`OpenClaw`、`Hermes` 这类外部智能体里，用尽量一致的命令去搜索、转存、下载、更新和修复

如果你是第一次接触这个仓库，优先看这个插件就够了。

## 适合谁

适合这些场景：

- 你想统一处理“找资源 -> 选资源 -> 转存到网盘”的流程
- 你既用 `115`，也用 `夸克`
- 你会同时用 `盘搜`、`影巢`、`MP/PT`
- 你希望外部智能体不要乱发挥，而是按固定命令稳定执行
- 你需要在 `Win/Mac` 上跑智能体、在 `NAS` 上跑 `MoviePilot`

## 主要能力

### 资源搜索

- `搜索 <片名>`：普通搜索，默认先盘搜
- `盘搜搜索 <片名>`：只看盘搜
- `影巢搜索 <片名>`：只看影巢
- `云盘搜索 <片名>`：盘搜 + 影巢
- `MP搜索 <片名>` / `PT搜索 <片名>`：走 MoviePilot 原生搜索/PT

### 资源执行

- `转存 <片名>`：云盘资源一条龙转存
- `夸克转存 <片名>`：优先选夸克资源并转存到夸克
- `115转存 <片名>`：优先选 115 资源并转存到 115
- `下载 <片名>`：走 MP/PT 下载链

### 更新与检查

- `更新检查 <片名>` / `检查 <片名>`
- `影巢签到`
- `影巢签到日志`

### 维护与修复

- `115登录`
- `115状态`
- `清空115转存目录`
- `清空夸克转存目录`
- `刷新影巢Cookie`
- `修复影巢签到`
- `刷新夸克Cookie`
- `修复夸克转存`

### MoviePilot 原生能力接入

除了云盘资源链，这个插件也已经接进了 `MoviePilot` 原生能力：

- 原生搜索
- PT 下载
- 订阅
- 下载任务
- 下载历史
- 入库历史
- 站点状态 / 下载器状态
- 热门探索 / 推荐

## 推荐使用方式

### 1. 你已经知道片名

优先这样用：

- `云盘搜索 片名`
- `转存 片名`
- `夸克转存 片名`
- `115转存 片名`
- `下载 片名`

### 2. 你想先看看是否更新

优先这样用：

- `更新检查 片名`
- `检查 片名`

### 3. 你只想盯单一来源

优先这样用：

- `盘搜搜索 片名`
- `影巢搜索 片名`
- `MP搜索 片名`
- `PT搜索 片名`

## 常用命令示例

```text
云盘搜索 21世纪大君夫人
盘搜搜索 低智商犯罪
影巢搜索 流浪地球2
转存 21世纪大君夫人
夸克转存 21世纪大君夫人
115转存 低智商犯罪
下载 沙丘2
更新检查 大君夫人
检查 低智商犯罪
影巢签到
修复影巢签到
刷新夸克Cookie
115登录
清空115转存目录
清空夸克转存目录
```

## 外部智能体怎么接

如果你只是直接在 `MoviePilot` 里点插件、调用原生能力，这一节可以先跳过。

如果你要接：

- `WorkBuddy`
- `OpenClaw`
- `Hermes`
- 其他外部智能体

那就需要安装 `agent-resource-officer` 的 `skill / helper`。

优先阅读：

- [`agent-resource-officer/SKILL.md`](../skills/agent-resource-officer/SKILL.md)
- [`AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md`](../docs/AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md)
- [`AGENT_RESOURCE_OFFICER_REMOTE_DEPLOY.md`](../docs/AGENT_RESOURCE_OFFICER_REMOTE_DEPLOY.md)

最短接入思路是：

1. `NAS / 本机 MoviePilot` 安装并启用本插件
2. 智能体所在机器安装 `agent-resource-officer skill / helper`
3. 配好 `ARO_BASE_URL` 和 `ARO_API_KEY`
4. 让智能体优先使用固定命令，不要自由改写

## 飞书入口

这个插件已经内置可选的飞书入口。

适合你想在飞书里直接发：

- 搜索
- 选择
- 转存
- 115 登录
- 影巢签到

如果你准备启用它，建议：

- 先关闭旧的 `FeishuCommandBridgeLong`
- 避免同一个飞书机器人被两个插件同时监听

## 和旧插件的关系

这个插件的定位是：**把旧的分散能力收成主线。**

它主要承接过这些旧链路的能力：

- `FeishuCommandBridgeLong`
- `HdhiveOpenApi`
- `QuarkShareSaver`

另外还有一个常见的“旧组合”：

- 旧飞书桥接插件
- 夸克分享转存插件
- `P115StrmHelper`
- 影巢 API / 影巢签到相关插件

这套旧组合仍然能用，但更适合兼容老环境，不适合作为后续主线继续扩展。

### 关于 P115StrmHelper

`Agent影视助手` 已经能处理很多 `115` 分享转存场景，但 `STRM` 生成、302、全量/增量同步、媒体库整理，仍建议继续交给 `P115StrmHelper`。

也就是说：

- `Agent影视助手`：更偏资源入口、搜索、转存、下载、更新、修复
- `P115StrmHelper`：更偏 `STRM`、同步、媒体库落地

## 新手最容易踩的坑

### 1. 外部智能体喜欢乱改命令

例如：

- 把 `云盘搜索` 偷换成 `盘搜搜索`
- 把 `更新检查` 改成普通搜索
- 把原始结果改写成“推荐资源 / 分析结论”

如果你接外部智能体，优先看：

- [`AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md`](../docs/AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md)

### 2. 影巢 Cookie 不建议手工抄

如果影巢签到失效，不建议手工找 Cookie。

更稳的方式是：

- 在浏览器登录 `https://hdhive.com`
- 然后运行本机导出工具

### 3. 夸克失败不一定是 Cookie 失效

这些情况不要误判成 Cookie 问题：

- 分享受限
- `41031`
- 分享者封禁

只有明确出现：

- `require login [guest]`
- `夸克登录态已过期`
- `当前夸克登录态不足`

才优先走夸克 Cookie 修复。

## 进一步阅读

如果你只是新手用户，到这里已经够用了。

如果你还想继续看更细的安装、接入和远程用法，再看这些文档：

- [`PLUGIN_INSTALL.md`](../docs/PLUGIN_INSTALL.md)
- [`AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md`](../docs/AGENT_RESOURCE_OFFICER_EXTERNAL_AGENTS.md)
- [`AGENT_RESOURCE_OFFICER_REMOTE_DEPLOY.md`](../docs/AGENT_RESOURCE_OFFICER_REMOTE_DEPLOY.md)
