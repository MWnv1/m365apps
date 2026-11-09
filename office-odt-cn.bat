@echo off
chcp 65001 >nul
setlocal EnableExtensions
title Office ODT 安装器（简体中文）

set "SETUP_URL=https://officecdn.microsoft.com/pr/wsus/setup.exe"
if defined ODT_SETUP_URL set "SETUP_URL=%ODT_SETUP_URL%"
set "SETUP_DIR=%temp%\office-odt-cn"
set "SETUP_EXE=%SETUP_DIR%\setup.exe"

:: ================= 提权 =================
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" >nul 2>&1
fsutil dirty query %systemdrive% >nul 2>&1 && goto :Privileges_got
if "%~1"=="--elevated" goto :noAdmin
cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~0", "--elevated", "", "runas", 1 > "%temp%\getadmin.vbs"
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

:menu
cls
echo ============================================================
echo             微软 Office 部署工具（ODT）安装器
echo                     简体中文定制版
echo ============================================================
echo  本工具只调用微软官方 ODT 部署 Office，不含任何激活/破解
echo  功能；Office 授权请自备合法密钥或 Microsoft 365 订阅。
echo ============================================================
echo.
echo  [ 安 装 ]
echo.
echo   1 - 微软 365 商业版 + Project + Visio（简中）
echo   2 - 微软 365 商业版（简中）
echo   3 - 微软 365 企业版 + Project + Visio（简中）
echo   4 - 微软 365 企业版（简中）
echo   5 - 微软 365 家庭版（简中）
echo   6 - Office LTSC 2024 专业增强版（简中，需批量许可）
echo   7 - Office LTSC 2021 专业增强版（简中，需批量许可）
echo   8 - 自定义配置（XMLFiles/my-config.xml）
echo.
echo  [ 卸 载 ]
echo.
echo   9 - 卸载全部 Office 产品
echo   0 - 仅卸载 Project / Visio
echo.
echo  [ 工 具 ]
echo.
echo   A - 查看已安装的 Office 产品 / 版本 / 通道
echo   B - 允许 OneDrive 个人版同步
echo   C - 禁用 OneDrive 个人版同步
echo   D - 移除 OneDrive 个人版同步策略
echo   E - 显示 Office 预览体验按钮
echo   F - 隐藏 Office 预览体验按钮
echo   G - 移除 Office 预览体验策略
echo   H - 移除 Office 更新通道策略
echo.
echo   Q - 退出
echo.
echo ============================================================
echo.
choice /c 1234567890ABCDEFGHQ /n /m "请输入选项: "
set "op=%errorlevel%"
set "DESC="
set "XML="

if "%op%"=="1" (
    set "DESC=微软 365 商业版 + Project + Visio（简中）"
    set "XML=XMLFiles/InstallOfficeProjectVisio-Business-CN.xml"
    goto runOffice
)
if "%op%"=="2" (
    set "DESC=微软 365 商业版（简中）"
    set "XML=XMLFiles/InstallOffice-Business-CN.xml"
    goto runOffice
)
if "%op%"=="3" (
    set "DESC=微软 365 企业版 + Project + Visio（简中）"
    set "XML=XMLFiles/InstallOfficeProjectVisio-Enterprise-CN.xml"
    goto runOffice
)
if "%op%"=="4" (
    set "DESC=微软 365 企业版（简中）"
    set "XML=XMLFiles/InstallOffice-Enterprise-CN.xml"
    goto runOffice
)
if "%op%"=="5" (
    set "DESC=微软 365 家庭版（简中）"
    set "XML=XMLFiles/InstallOffice-Home-CN.xml"
    goto runOffice
)
if "%op%"=="6" (
    set "DESC=Office LTSC 2024 专业增强版（简中）"
    set "XML=XMLFiles/InstallOffice-LTSC2024-CN.xml"
    goto runOffice
)
if "%op%"=="7" (
    set "DESC=Office LTSC 2021 专业增强版（简中）"
    set "XML=XMLFiles/InstallOffice-LTSC2021-CN.xml"
    goto runOffice
)
if "%op%"=="8" (
    set "DESC=自定义配置"
    set "XML=XMLFiles/my-config.xml"
    goto runOffice
)
if "%op%"=="9" (
    set "DESC=卸载全部 Office 产品"
    set "XML=XMLFiles/UninstallOffice.xml"
    goto runOffice
)
if "%op%"=="10" (
    set "DESC=仅卸载 Project / Visio"
    set "XML=XMLFiles/UninstallProjectVisio.xml"
    goto runOffice
)
if "%op%"=="11" goto showInstalled
if "%op%"=="12" goto tweakAllowOneDrive
if "%op%"=="13" goto tweakBlockOneDrive
if "%op%"=="14" goto tweakRemoveOneDrive
if "%op%"=="15" goto tweakShowInsider
if "%op%"=="16" goto tweakHideInsider
if "%op%"=="17" goto tweakRemoveInsider
if "%op%"=="18" goto tweakRemoveBranch
if "%op%"=="19" goto quit
goto menu

:runOffice
if not exist "%XML%" (
    echo.
    echo 错误：找不到配置文件 "%XML%"
    echo 请确认 XMLFiles 目录与本脚本在同一文件夹下。
    goto pauseAndMenu
)
echo.
echo ------------------------------------------------------------
echo 准备 Office 部署工具（ODT）...
echo ------------------------------------------------------------
if not exist "%SETUP_DIR%" mkdir "%SETUP_DIR%" >nul 2>&1
if exist "%SETUP_EXE%" del /f /q "%SETUP_EXE%" >nul 2>&1
echo 下载源：%SETUP_URL%
echo 正在从微软下载最新 setup.exe ...
where curl.exe >nul 2>&1
if errorlevel 1 goto downloadPS
curl.exe -fSL -o "%SETUP_EXE%" "%SETUP_URL%"
goto downloadDone

:downloadPS
echo 未检测到 curl.exe，改用 PowerShell 下载...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri '%SETUP_URL%' -OutFile '%SETUP_EXE%'"

:downloadDone
if not exist "%SETUP_EXE%" (
    echo.
    echo 错误：setup.exe 下载失败。请检查网络后重试。
    goto cleanup
)
echo 下载完成。
echo.
echo 即将执行：%DESC%
echo 命令：setup.exe /configure "%XML%"
echo 安装期间请勿关闭本窗口，Office 会在后台继续下载安装。
echo.
"%SETUP_EXE%" /configure "%XML%"
goto cleanup

:showInstalled
echo.
echo ------------------------------------------------------------
echo 已安装的 Office 信息
echo ------------------------------------------------------------
set "CR=HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
set "CR32=HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration"
echo [产品 ID]
reg query "%CR%" /v ProductReleaseIds 2>nul
reg query "%CR32%" /v ProductReleaseIds 2>nul
echo.
echo [版本号]
reg query "%CR%" /v VersionToReport 2>nul
reg query "%CR32%" /v VersionToReport 2>nul
echo.
echo [位数]
reg query "%CR%" /v Platform 2>nul
reg query "%CR32%" /v Platform 2>nul
echo.
echo [更新通道]
reg query "%CR%" /v CDNBaseUrl 2>nul
reg query "%CR32%" /v CDNBaseUrl 2>nul
echo.
echo 若以上全部显示“找不到”，说明本机未通过 Click-to-Run 安装 Office。
goto pauseAndMenu

:tweakAllowOneDrive
echo.
reg add "HKCU\Software\Microsoft\OneDrive" /v "DisablePersonalSync" /t REG_DWORD /d 0 /f >nul 2>&1
echo 已允许 OneDrive 个人版同步。
goto pauseAndMenu

:tweakBlockOneDrive
echo.
reg add "HKCU\Software\Microsoft\OneDrive" /v "DisablePersonalSync" /t REG_DWORD /d 1 /f >nul 2>&1
echo 已禁用 OneDrive 个人版同步。
goto pauseAndMenu

:tweakRemoveOneDrive
echo.
reg delete "HKCU\Software\Microsoft\OneDrive" /v "DisablePersonalSync" /f >nul 2>&1
echo 已移除 OneDrive 个人版同步策略。
goto pauseAndMenu

:tweakShowInsider
echo.
reg add "HKCU\Software\Policies\Microsoft\office\16.0\common" /v "insiderslabbehavior" /t REG_DWORD /d 2 /f >nul 2>&1
echo 已显示 Office 预览体验按钮。
goto pauseAndMenu

:tweakHideInsider
echo.
reg add "HKCU\Software\Policies\Microsoft\office\16.0\common" /v "insiderslabbehavior" /t REG_DWORD /d 0 /f >nul 2>&1
echo 已隐藏 Office 预览体验按钮。
goto pauseAndMenu

:tweakRemoveInsider
echo.
reg delete "HKCU\Software\Policies\Microsoft\office\16.0\common" /v "insiderslabbehavior" /f >nul 2>&1
echo 已移除 Office 预览体验按钮策略。
goto pauseAndMenu

:tweakRemoveBranch
echo.
reg delete "HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate" /v "updatebranch" /f >nul 2>&1
echo 已移除 Office 更新通道策略。
goto pauseAndMenu

:pauseAndMenu
echo.
pause
goto menu

:cleanup
echo.
echo ============================================================
echo 命令已结束。请稍等片刻，再查看 Office 是否开始安装。
echo 可用主菜单“A”查看已安装产品。
echo 正在清理临时文件...
if exist "%SETUP_EXE%" del /f /q "%SETUP_EXE%" >nul 2>&1
if exist "%SETUP_DIR%" rmdir "%SETUP_DIR%" >nul 2>&1
echo.
pause
goto menu

:quit
endlocal
exit /b 0