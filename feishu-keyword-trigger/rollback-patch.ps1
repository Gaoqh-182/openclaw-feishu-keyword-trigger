# 飞书关键词触发功能 - 回滚脚本
# 使用方法：在 PowerShell 中运行 .\rollback-patch.ps1

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "飞书关键词触发功能 - 回滚脚本" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$BACKUP_DIR = "C:\Users\xiaohongPC\.openclaw\workspace\backup\feishu-keyword-trigger"
$FEISHU_SRC_DIR = "C:\Users\xiaohongPC\AppData\Roaming\npm\node_modules\openclaw\extensions\feishu\src"
$CONFIG_FILE = "C:\Users\xiaohongPC\.openclaw\openclaw.json"

# 检查备份是否存在
Write-Host "[1/4] 检查备份文件..." -ForegroundColor Yellow
if (!(Test-Path "$BACKUP_DIR\bot.ts.original")) {
    Write-Host "错误：备份文件不存在！无法回滚。" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 备份文件存在" -ForegroundColor Green

# 恢复 bot.ts
Write-Host ""
Write-Host "[2/4] 恢复 bot.ts..." -ForegroundColor Yellow

Copy-Item "$BACKUP_DIR\bot.ts.original" "$FEISHU_SRC_DIR\bot.ts" -Force
Write-Host "✓ bot.ts 已恢复" -ForegroundColor Green

# 恢复 channel.ts
Write-Host ""
Write-Host "[3/4] 恢复 channel.ts..." -ForegroundColor Yellow

Copy-Item "$BACKUP_DIR\channel.ts.original" "$FEISHU_SRC_DIR\channel.ts" -Force
Write-Host "✓ channel.ts 已恢复" -ForegroundColor Green

# 恢复配置文件
Write-Host ""
Write-Host "[4/4] 恢复配置文件..." -ForegroundColor Yellow

Copy-Item "$BACKUP_DIR\openclaw.json.original" $CONFIG_FILE -Force
Write-Host "✓ 配置文件已恢复" -ForegroundColor Green

# 重启网关
Write-Host ""
Write-Host "重启 OpenClaw 网关..." -ForegroundColor Yellow

& openclaw gateway restart

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "✓ 回滚完成！已恢复到修改前状态" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "当前配置：需要 @机器人 才会回复" -ForegroundColor Yellow
