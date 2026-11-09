@echo off
chcp 65001 >nul
setlocal EnableExtensions
title 一键安装 Office（简体中文）

:: ============ 想换安装内容，只改下面这一行 ============
:: 可选：XMLFiles/InstallOffice-Enterprise-CN.xml（365 企业版）
::       XMLFiles/InstallOffice-Business-CN.xml（365 商业版）
::       XMLFiles/InstallOffice-Home-CN.xml（365 家庭版）
::       XMLFiles/InstallOffice-LTSC2024-CN.xml（LTSC 2024）
::       XMLFiles/InstallOffice-LTSC2021-CN.xml（LTSC 2021）
set "XML=XMLFiles/InstallOffice-Enterprise-CN.xml"
:: 把 XML 文件拖到本脚本上，也会用它
if not "%~1"=="" set "XML=%~1"

set "SETUP_URL=https://officecdn.microsoft.com/pr/wsus/setup.exe"
if defined ODT_SETUP_URL set "SETUP_URL=%ODT_SETUP_URL%"
set "SETUP_DIR=%temp%\office-odt-cn"
set "SETUP_EXE=%SETUP_DIR%\setup.exe"

:: ================= 提权 =================
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" >nul 2>&1
fsutil dirty query %systemdrive% >nul 2>&1 && goto :Privileges_got
if "%~2"=="--elevated" goto :noAdmin
cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~0", "%~1", "--elevated", "runas", 1 > "%temp%\getadmin.vbs"
cscript //nologo "%temp%\getadmin.vbs"
exit /b

:noAdmin
echo.
echo 提权失败：请右键本文件，选择“以管理员身份运行”。
echo.
pause
exit /b 1

:Privileges_got
cd /d "%~dp0"

if not exist "%XML%" (
    echo.
    echo 错误：找不到配置文件 "%XML%"
    echo 请确认脚本与 XMLFiles 目录在同一文件夹下，或把正确的 XML 拖到本脚本上。
    echo.
    pause
    exit /b 1
)

cls
echo ============================================================
echo                一键安装 Office
echo ============================================================
echo  配置：%XML%
echo  说明：本脚本仅调用微软官方 ODT 部署 Office，不含任何激活功能。
echo        请确保你持有合法授权（零售密钥 / 365 订阅 / 组织批量许可）。
echo ============================================================
echo.
echo 建议先关闭所有 Office 程序（Word / Excel / PowerPoint 等）。
echo 按任意键开始安装，或关闭窗口取消...
pause >nul

echo.
echo [1/3] 准备 Office 部署工具...
if not exist "%SETUP_DIR%" mkdir "%SETUP_DIR%" >nul 2>&1
if exist "%SETUP_EXE%" del /f /q "%SETUP_EXE%" >nul 2>&1
echo     下载源：%SETUP_URL%
where curl.exe >nul 2>&1
if errorlevel 1 goto downloadPS
curl.exe -fSL -o "%SETUP_EXE%" "%SETUP_URL%"
goto downloadDone

:downloadPS
echo     未检测到 curl.exe，改用 PowerShell 下载...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri '%SETUP_URL%' -OutFile '%SETUP_EXE%'"

:downloadDone
if not exist "%SETUP_EXE%" (
    echo.
    echo 错误：setup.exe 下载失败，请检查网络后重试。
    echo 如果国内直连很慢，可先设置环境变量 ODT_SETUP_URL 指向可用源。
    echo.
    pause
    exit /b 1
)

echo.
echo [2/3] 正在安装，Office 会在后台下载安装包，耗时取决于网速...
echo     安装期间请勿关闭本窗口。
echo.
"%SETUP_EXE%" /configure "%XML%"

echo.
echo [3/3] 安装流程结束，当前本机 Office 状态：
set "CR=HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
set "CR32=HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration"
echo.
echo   [产品 ID]
reg query "%CR%" /v ProductReleaseIds 2>nul
reg query "%CR32%" /v ProductReleaseIds 2>nul
echo.
echo   [版本号]
reg query "%CR%" /v VersionToReport 2>nul
reg query "%CR32%" /v VersionToReport 2>nul
echo.
echo 若未看到产品信息，请稍等几分钟后重新运行本脚本查看，或看窗口上方 ODT 报错。

echo.
echo 正在清理临时文件...
if exist "%SETUP_EXE%" del /f /q "%SETUP_EXE%" >nul 2>&1
if exist "%SETUP_DIR%" rmdir "%SETUP_DIR%" >nul 2>&1
echo.
echo 完成。首次启动 Office 时登录 Microsoft 365 账号或输入产品密钥即可完成授权。
echo.
pause
endlocal
exit /b 0