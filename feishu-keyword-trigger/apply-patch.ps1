# 飞书关键词触发功能 - 快速操作脚本
# 使用方法：在 PowerShell 中运行 .\apply-patch.ps1

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "飞书关键词触发功能 - 应用补丁脚本" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$BACKUP_DIR = "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger"
$FEISHU_SRC_DIR = "C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src"
$CONFIG_FILE = "C:\Users\xiaohongPC\.openclaw\openclaw.json"

# 检查备份是否存在
Write-Host "[1/5] 检查备份文件..." -ForegroundColor Yellow
if (!(Test-Path "$BACKUP_DIR\bot.ts.original")) {
    Write-Host "错误：备份文件不存在！请先运行备份。" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 备份文件存在" -ForegroundColor Green

# 应用 bot.ts 修改
Write-Host ""
Write-Host "[2/5] 修改 bot.ts..." -ForegroundColor Yellow

$botTsPath = "$FEISHU_SRC_DIR\bot.ts"
$botTsContent = Get-Content $botTsPath -Raw

# 查找并替换关键代码段
$oldCode = @"
    if (requireMention && !ctx.mentionedBot) {
      log(`feishu[\${account.accountId}]: message in group \${ctx.chatId} did not mention bot`);
"@

$newCode = @"
    // --- 关键词触发功能 ---
    // 检查消息是否包含触发关键词（无需@机器人）
    const triggerKeywords = feishuCfg?.triggerKeywords || [];
    const hasTriggerKeyword = triggerKeywords.length > 0 && 
      triggerKeywords.some((kw: string) => ctx.content.includes(kw));

    if (requireMention && !ctx.mentionedBot && !hasTriggerKeyword) {
      log(`feishu[\${account.accountId}]: message in group \${ctx.chatId} did not mention bot and no trigger keyword`);
"@

if ($botTsContent -match [regex]::Escape($oldCode)) {
    $newContent = $botTsContent -replace [regex]::Escape($oldCode), $newCode
    Set-Content $botTsPath $newContent -Encoding UTF8
    Write-Host "✓ bot.ts 修改成功" -ForegroundColor Green
} else {
    Write-Host "⚠ 未找到目标代码段，可能已修改或版本不同" -ForegroundColor Yellow
    Write-Host "  请手动检查文件：$botTsPath" -ForegroundColor Gray
}

# 应用 channel.ts 修改
Write-Host ""
Write-Host "[3/5] 修改 channel.ts..." -ForegroundColor Yellow

$channelTsPath = "$FEISHU_SRC_DIR\channel.ts"
$channelTsContent = Get-Content $channelTsPath -Raw

$oldSchema = 'requireMention: { type: "boolean" },'
$newSchema = @"requireMention: { type: "boolean" },
    triggerKeywords: { type: "array", items: { type: "string" } },"@

if ($channelTsContent -match [regex]::Escape($oldSchema)) {
    $newContent = $channelTsContent -replace [regex]::Escape($oldSchema), $newSchema
    Set-Content $channelTsPath $newContent -Encoding UTF8
    Write-Host "✓ channel.ts 修改成功" -ForegroundColor Green
} else {
    Write-Host "⚠ 未找到目标代码段，可能已修改或版本不同" -ForegroundColor Yellow
    Write-Host "  请手动检查文件：$channelTsPath" -ForegroundColor Gray
}

# 应用配置文件修改
Write-Host ""
Write-Host "[4/5] 修改配置文件..." -ForegroundColor Yellow

$configContent = Get-Content $CONFIG_FILE -Raw

# 检查是否已包含 triggerKeywords
if ($configContent -match '"triggerKeywords"') {
    Write-Host "✓ 配置文件已包含 triggerKeywords，跳过" -ForegroundColor Green
} else {
    # 在 groupPolicy 后添加 triggerKeywords
    $newConfig = $configContent -replace 
      '"groupPolicy":\s*"open"', 
      '"groupPolicy": "open",`n      "triggerKeywords": ["傻妞", "傻妞在吗", "叫傻妞"]'
    
    Set-Content $CONFIG_FILE $newConfig -Encoding UTF8
    Write-Host "✓ 配置文件修改成功" -ForegroundColor Green
}

# 重启网关
Write-Host ""
Write-Host "[5/5] 重启 OpenClaw 网关..." -ForegroundColor Yellow

Write-Host "执行：openclaw gateway restart" -ForegroundColor Gray
& openclaw gateway restart

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "✓ 补丁应用完成！" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "测试方法：" -ForegroundColor Yellow
Write-Host "1. 在群里发送 '傻妞在吗' - 应该回复" -ForegroundColor White
Write-Host "2. 在群里发送 '今天天气不错' - 应该不回复" -ForegroundColor White
Write-Host ""
Write-Host "如需回滚，运行：.\rollback-patch.ps1" -ForegroundColor Gray
