@echo off
chcp 65001 >nul
setlocal EnableExtensions
title 一键卸载 Office

set "SETUP_URL=https://officecdn.microsoft.com/pr/wsus/setup.exe"
if defined ODT_SETUP_URL set "SETUP_URL=%ODT_SETUP_URL%"
set "SETUP_DIR=%temp%\office-odt-cn"
set "SETUP_EXE=%SETUP_DIR%\setup.exe"
set "XML=XMLFiles/UninstallOffice.xml"

:: ================= 提权 =================
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" >nul 2>&1
fsutil dirty query %systemdrive% >nul 2>&1 && goto :Privileges_got
if "%~1"=="--elevated" goto :noAdmin
cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~0", "", "--elevated", "runas", 1 > "%temp%\getadmin.vbs"
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

cls
echo ============================================================
echo                一键卸载全部 Office
echo ============================================================
echo  本操作会移除本机由 Click-to-Run 安装的全部 Office 产品。
echo  文档与本地设置不会被删除，但请先自行确认没在跑 Office 程序。
echo ============================================================
echo.
echo 确认卸载请按任意键，关闭窗口可取消...
pause >nul

taskkill /f /im WINWORD.EXE >nul 2>&1
taskkill /f /im EXCEL.EXE >nul 2>&1
taskkill /f /im POWERPNT.EXE >nul 2>&1
taskkill /f /im OUTLOOK.EXE >nul 2>&1
taskkill /f /im MSACCESS.EXE >nul 2>&1
taskkill /f /im ONENOTE.EXE >nul 2>&1

echo.
echo [1/2] 准备 Office 部署工具...
if not exist "%SETUP_DIR%" mkdir "%SETUP_DIR%" >nul 2>&1
if exist "%SETUP_EXE%" del /f /q "%SETUP_EXE%" >nul 2>&1
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
    echo.
    pause
    exit /b 1
)

echo.
echo [2/2] 正在卸载，请稍等...
"%SETUP_EXE%" /configure "%XML%"

echo.
echo 卸载完成。正在清理临时文件...
if exist "%SETUP_EXE%" del /f /q "%SETUP_EXE%" >nul 2>&1
if exist "%SETUP_DIR%" rmdir "%SETUP_DIR%" >nul 2>&1
echo.
echo 建议重启电脑，确保卸载彻底完成。
echo.
pause
endlocal
exit /b 0