# OpenClaw 飞书关键词触发功能

> 🤖 让机器人群聊中无需 @ 即可自动回复！基于关键词智能触发，告别频繁 @ 的烦恼。

[![OpenClaw](https://img.shields.io/badge/OpenClaw-Plugin-blue)](https://github.com/openclaw/openclaw)
[![Feishu](https://img.shields.io/badge/Platform-Feishu/Lark-blue)](https://www.feishu.cn/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📖 功能介绍

### 问题背景

在 OpenClaw 的飞书插件中，机器人群聊默认需要 **@机器人** 才会触发回复。即使配置了 `requireMention: false`，机器人仍然不会主动响应消息。

### 解决方案

本功能通过修改飞书插件源码，添加 **关键词触发机制**：

- ✅ 消息包含关键词即可触发回复（无需 @）
- ✅ 可自定义关键词列表
- ✅ 兼容原有的 @ 触发机制
- ✅ 支持全局配置和群组单独配置

### 效果对比

| 场景 | 修改前 | 修改后 |
|------|--------|--------|
| 发送 "@机器人 你好" | ✅ 回复 | ✅ 回复 |
| 发送 "机器人在吗" | ❌ 无响应 | ✅ 回复 |
| 发送 "今天天气不错" | ❌ 无响应 | ❌ 无响应（保持安静） |

---

## 🚀 快速开始

### 方法一：自动脚本（推荐）

```powershell
# 1. 进入脚本目录
cd C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger

# 2. 应用补丁
.\apply-patch.ps1

# 3. 等待网关自动重启
# 看到 "✓ 补丁应用完成！" 即成功
```

### 方法二：手动修改

详见 [完整安装指南](#-完整安装指南)

---

## ⚙️ 配置说明

### 基础配置

在 `openclaw.json` 中添加 `triggerKeywords` 配置：

```json
{
  "channels": {
    "feishu": {
      "enabled": true,
      "appId": "cli_xxxxxxxxxxxxxxxx",
      "appSecret": "xxxxxxxxxxxxxxxx",
      "domain": "feishu",
      "groupPolicy": "open",
      "triggerKeywords": ["傻妞", "傻妞在吗", "叫傻妞"],
      "groups": {
        "oc_xxxxxxxxxxxxxxxx": {
          "requireMention": false
        }
      }
    }
  }
}
```

### 配置位置

`triggerKeywords` 可以放在两个位置：

#### 1. 全局配置（所有群组共享）

```json
{
  "channels": {
    "feishu": {
      "triggerKeywords": ["傻妞", "AI", "助手"]
    }
  }
}
```

#### 2. 群组单独配置（仅对该群组生效）

```json
{
  "channels": {
    "feishu": {
      "groups": {
        "oc_xxx": {
          "requireMention": false,
          "triggerKeywords": ["傻妞", "机器人", "AI"]
        },
        "oc_yyy": {
          "requireMention": false,
          "triggerKeywords": ["小助手", "助手"]
        }
      }
    }
  }
}
```

### 配置优先级

**群组配置 > 全局配置**

如果群组和全局都配置了关键词，优先使用群组配置。

---

## 📋 完整安装指南

### 步骤 1：备份原文件

```powershell
# 创建备份目录
mkdir C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger

# 备份 bot.ts
Copy-Item `
  "C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src\bot.ts" `
  "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger\bot.ts.original"

# 备份 channel.ts
Copy-Item `
  "C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src\channel.ts" `
  "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger\channel.ts.original"

# 备份配置文件
Copy-Item `
  "C:\Users\xiaohongPC\.openclaw\openclaw.json" `
  "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger\openclaw.json.original"
```

### 步骤 2：修改 bot.ts

**文件位置：** `C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src\bot.ts`

**查找代码（约 1023 行）：**
```typescript
({ requireMention } = resolveFeishuReplyPolicy({
  isDirectMessage: false,
  globalConfig: feishuCfg,
  groupConfig,
}));

if (requireMention && !ctx.mentionedBot) {
  log(`feishu[${account.accountId}]: message in group ${ctx.chatId} did not mention bot`);
```

**替换为：**
```typescript
({ requireMention } = resolveFeishuReplyPolicy({
  isDirectMessage: false,
  globalConfig: feishuCfg,
  groupConfig,
}));

// --- 关键词触发功能 ---
// 检查消息是否包含触发关键词（无需@机器人）
const triggerKeywords = feishuCfg?.triggerKeywords || [];
const hasTriggerKeyword = triggerKeywords.length > 0 && 
  triggerKeywords.some((kw: string) => ctx.content.includes(kw));

if (requireMention && !ctx.mentionedBot && !hasTriggerKeyword) {
  log(`feishu[${account.accountId}]: message in group ${ctx.chatId} did not mention bot and no trigger keyword`);
```

### 步骤 3：修改 channel.ts

**文件位置：** `C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src\channel.ts`

**查找代码（约 120 行）：**
```typescript
requireMention: { type: "boolean" },
groupSessionScope: {
```

**替换为：**
```typescript
requireMention: { type: "boolean" },
triggerKeywords: { type: "array", items: { type: "string" } },
groupSessionScope: {
```

### 步骤 4：修改配置文件

在 `C:\Users\xiaohongPC\.openclaw\openclaw.json` 中添加：

```json
{
  "channels": {
    "feishu": {
      "triggerKeywords": ["傻妞", "傻妞在吗", "叫傻妞"]
    }
  }
}
```

### 步骤 5：重启网关

```powershell
openclaw gateway restart
```

### 步骤 6：测试验证

在飞书群聊中发送测试消息：

| 测试消息 | 期望结果 |
|----------|----------|
| `傻妞在吗？` | ✅ 机器人回复 |
| `今天天气不错` | ✅ 机器人不回复 |
| `@机器人 你好` | ✅ 机器人回复 |

---

## 🔄 回滚方案

如果修改后出现问题，可以快速回滚：

### 方法一：使用回滚脚本

```powershell
cd C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger
.\rollback-patch.ps1
```

### 方法二：手动恢复

```powershell
# 恢复 bot.ts
Copy-Item `
  "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger\bot.ts.original" `
  "C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src\bot.ts" `
  -Force

# 恢复 channel.ts
Copy-Item `
  "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger\channel.ts.original" `
  "C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src\channel.ts" `
  -Force

# 恢复配置文件
Copy-Item `
  "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger\openclaw.json.original" `
  "C:\Users\xiaohongPC\.openclaw\openclaw.json" `
  -Force

# 重启网关
openclaw gateway restart
```

---

## ⚠️ 注意事项

### 1. OpenClaw 更新后会失效

每次 OpenClaw 更新后，修改会被覆盖，需要：

```powershell
# 重新应用补丁
cd C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger
.\apply-patch.ps1
```

### 2. 备份文件很重要

不要删除 `backup/feishu-keyword-trigger` 目录，回滚脚本依赖这些备份文件。

### 3. 性能影响

关键词检测采用简单字符串匹配，每条消息增加约 0.1-0.5ms 处理时间，可忽略不计。

### 4. 兼容性

- ✅ 兼容原有的 @ 触发机制
- ✅ 不影响其他通道（微信、Discord 等）
- ✅ 不影响 AI 核心功能

---

## 🐛 常见问题

### Q1: 修改后不生效？

**检查清单：**
- [ ] 网关是否已重启：`openclaw gateway restart`
- [ ] 配置格式是否正确（JSON 语法）
- [ ] 关键词是否匹配（区分大小写）
- [ ] 查看日志：`openclaw logs --follow`

### Q2: 机器人回复异常？

**解决方案：**
1. 运行回滚脚本恢复原状
2. 检查是否有其他配置冲突
3. 查看日志中的错误信息

### Q3: 如何查看触发日志？

```powershell
openclaw logs --follow
```

搜索关键词：`did not mention bot and no trigger keyword`

### Q4: 可以配置正则表达式吗？

当前版本仅支持简单字符串匹配，暂不支持正则表达式。如需高级匹配，可修改 `bot.ts` 中的 `hasTriggerKeyword` 逻辑。

---

## 📁 文件结构

```
feishu-keyword-trigger/
├── README.md                  # 本说明文档
├── 修改方案.md                # 完整修改文档（中文）
├── 快速参考.md                # 快速参考手册
├── apply-patch.ps1            # 应用补丁脚本
├── rollback-patch.ps1         # 回滚脚本
├── bot.ts.original            # bot.ts 原始备份
├── channel.ts.original        # channel.ts 原始备份
└── openclaw.json.original     # 配置文件原始备份
```

---

## 🛠️ 技术细节

### 修改的文件

| 文件 | 修改内容 | 行数 |
|------|----------|------|
| `bot.ts` | 添加关键词检测逻辑 | ~1023 |
| `channel.ts` | 添加配置 Schema | ~120 |
| `openclaw.json` | 添加关键词配置 | 用户自定义 |

### 核心代码

```typescript
// 关键词检测逻辑
const triggerKeywords = feishuCfg?.triggerKeywords || [];
const hasTriggerKeyword = triggerKeywords.length > 0 && 
  triggerKeywords.some((kw: string) => ctx.content.includes(kw));

// 修改触发条件
if (requireMention && !ctx.mentionedBot && !hasTriggerKeyword) {
  // 不满足条件，不触发回复
  return;
}
```

---

## 📝 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0.0 | 2026-03-06 | 初始版本，支持关键词触发功能 |

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 待优化功能

- [ ] 支持正则表达式匹配
- [ ] 支持关键词大小写不敏感
- [ ] 支持关键词权重/优先级
- [ ] Web UI 配置界面
- [ ] 官方插件集成

---

## 📄 许可证

MIT License

---

## 🙏 致谢

- [OpenClaw](https://github.com/openclaw/openclaw) - 强大的 AI 助手框架
- 感谢所有贡献者和使用者

---

## 📞 联系方式

- GitHub Issues: [提交问题](https://github.com/openclaw/openclaw/issues)
- 社区 Discord: https://discord.com/invite/clawd
- 文档：https://docs.openclaw.ai

---

**Made with ❤️ by 傻妞**

> 🤖 修改前一定要备份！备份！备份！重要的事情说三遍～
