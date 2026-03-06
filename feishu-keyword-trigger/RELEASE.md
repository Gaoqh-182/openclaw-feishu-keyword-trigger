# GitHub Release 说明

## 📦 发布包内容

本发布包包含 OpenClaw 飞书关键词触发功能的完整补丁和文档。

### 文件清单

```
feishu-keyword-trigger/
├── README.md                  # 完整功能说明（中英文）
├── 修改方案.md                # 详细修改文档（中文）
├── 快速参考.md                # 快速参考手册（中文）
├── apply-patch.ps1            # 应用补丁脚本（PowerShell）
├── rollback-patch.ps1         # 回滚脚本（PowerShell）
├── bot.ts.original            # bot.ts 原始备份（参考）
├── channel.ts.original        # channel.ts 原始备份（参考）
└── openclaw.json.original     # 配置文件原始备份（参考）
```

---

## 🚀 使用方法

### 快速开始（3 步搞定）

```powershell
# 1. 下载并解压本发布包到任意目录
# 2. 打开 PowerShell，进入解压后的目录
cd C:\path\to\feishu-keyword-trigger

# 3. 运行应用脚本
.\apply-patch.ps1
```

脚本会自动：
- ✅ 检查备份文件
- ✅ 修改 bot.ts（添加关键词检测）
- ✅ 修改 channel.ts（添加配置 Schema）
- ✅ 修改 openclaw.json（添加关键词配置）
- ✅ 重启 OpenClaw 网关

---

## ⚙️ 配置示例

### 基础配置

在 `openclaw.json` 中添加：

```json
{
  "channels": {
    "feishu": {
      "triggerKeywords": ["傻妞", "傻妞在吗", "叫傻妞"]
    }
  }
}
```

### 高级配置（群组单独配置）

```json
{
  "channels": {
    "feishu": {
      "groupPolicy": "open",
      "triggerKeywords": ["傻妞", "AI", "助手"],
      "groups": {
        "oc_xxx": {
          "requireMention": false,
          "triggerKeywords": ["傻妞", "机器人"]
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

---

## ✅ 测试方法

在飞书群聊中发送以下消息：

| 测试消息 | 期望结果 |
|----------|----------|
| `傻妞在吗？` | ✅ 机器人回复 |
| `今天天气不错` | ✅ 机器人不回复（保持安静） |
| `@机器人 你好` | ✅ 机器人回复 |

---

## 🔄 回滚方法

如果修改后出现问题，运行回滚脚本：

```powershell
.\rollback-patch.ps1
```

或手动恢复备份文件。

---

## ⚠️ 注意事项

1. **OpenClaw 更新后** - 修改会被覆盖，需要重新运行 `apply-patch.ps1`
2. **备份文件** - 不要删除备份目录，回滚脚本依赖这些文件
3. **调试日志** - 运行 `openclaw logs --follow` 查看详细日志

---

## 🐛 常见问题

### Q: 修改后不生效？

**A:** 
1. 确认网关已重启：`openclaw gateway restart`
2. 检查配置格式（JSON 语法）
3. 查看日志：`openclaw logs --follow`

### Q: 如何查看触发日志？

**A:** 运行 `openclaw logs --follow`，搜索 `trigger keyword` 关键词。

---

## 📋 系统要求

- OpenClaw v2026.3.2 或更高版本
- Windows PowerShell 5.1 或更高版本
- 飞书开放平台应用（已配置机器人）

---

## 📄 许可证

MIT License

---

## 🙏 致谢

- OpenClaw 项目：https://github.com/openclaw/openclaw
- 文档：https://docs.openclaw.ai

---

**Made with ❤️**
