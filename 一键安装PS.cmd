@echo off
chcp 65001 >nul
cd /d "%~dp0"

if not exist "%~dp0install.ps1" (
    echo 找不到 install.ps1，请确认解压完整、文件与 XMLFiles 目录未被拆散。
    pause
    exit /b 1
)

:: 尝试解除文件锁定标记（被 SmartScreen 拦时有用）
powershell -NoProfile -Command "Unblock-File -LiteralPath '%~dp0install.ps1' -ErrorAction SilentlyContinue" >nul 2>&1

:: 静默运行，参数可透传，例如：一键安装PS.cmd -Product Business
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*

if errorlevel 1 (
    echo.
    echo 安装未完成，请看上方黄字/红字提示，日志在脚本同目录。
    pause
)
