<#
    install.ps1 — Office ODT 一键安装（PowerShell 版）

    推荐双击同目录的「一键安装PS.cmd」；也可手动运行：
        powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1

    参数（全部可省略，省略即按默认全自动执行，不会弹任何提问）：
        -Config   <xml 路径>   直接使用指定 XML（会忽略下面三个参数）
        -Product  Enterprise | Business | Home | LTSC2024 | LTSC2021
        -Language zh-CN | en-US
        -Bitness  64 | 32

    每次运行都会重新下载微软官方 ODT setup.exe，并由它拉取目标通道的最新版本。
    本脚本仅调用官方 ODT，不包含任何激活、破解、KMS 模拟代码。
    授权请自备：零售密钥 / Microsoft 365 订阅 / 组织批量许可。
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Config = '',
    [ValidateSet('Enterprise', 'Business', 'Home', 'LTSC2024', 'LTSC2021')][string]$Product = 'Enterprise',
    [ValidateSet('zh-CN', 'en-US')][string]$Language = 'zh-CN',
    [ValidateSet(32, 64)][int]$Bitness = 64
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogPath = Join-Path $ScriptDir ('install-log-{0}.txt' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$TempDir = Join-Path $env:TEMP 'office-odt-cn'
$SetupExe = Join-Path $TempDir 'setup.exe'
$SetupUrl = if ($env:ODT_SETUP_URL) { $env:ODT_SETUP_URL } else { 'https://officecdn.microsoft.com/pr/wsus/setup.exe' }

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

# ---------- 自动提权（唯一需要你点一下的地方） ----------
if (-not (Test-IsAdmin)) {
    Write-Host '需要管理员权限，正在请求提权（请在 UAC 弹窗中点“是”）...' -ForegroundColor Yellow
    $argString = '-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $PSCommandPath
    if ($Config) {
        $argString += ' -Config "{0}"' -f $Config
    } else {
        $argString += ' -Product {0} -Language {1} -Bitness {2}' -f $Product, $Language, $Bitness
    }
    Start-Process -FilePath 'powershell.exe' -ArgumentList $argString -Verb RunAs
    exit 0
}

try { Start-Transcript -Path $LogPath -Append | Out-Null } catch { $LogPath = $null }

$exitCode = 0

try {
    Write-Host '=============================================================' -ForegroundColor Cyan
    Write-Host '            Office ODT 一键安装（PowerShell）' -ForegroundColor Cyan
    Write-Host '=============================================================' -ForegroundColor Cyan
    Write-Host '本脚本只调用微软官方 ODT，不含任何激活/破解功能。' -ForegroundColor DarkGray

    # ---------- 准备 XML ----------
    if ($Config) {
        if (-not [IO.Path]::IsPathRooted($Config)) { $Config = Join-Path $ScriptDir $Config }
        if (-not (Test-Path -LiteralPath $Config)) { throw "找不到配置文件：$Config" }
        $ConfigPath = $Config
        $ProductLabel = '自定义配置 ' + (Split-Path -Leaf $Config)
    } else {
        switch ($Product) {
            'Enterprise' { $ProductId = 'O365ProPlusRetail';  $Channel = 'Current' }
            'Business'   { $ProductId = 'O365BusinessRetail'; $Channel = 'Current' }
            'Home'       { $ProductId = 'O365HomePremRetail'; $Channel = 'Current' }
            'LTSC2024'   { $ProductId = 'ProPlus2024Volume';  $Channel = 'PerpetualVL2024' }
            'LTSC2021'   { $ProductId = 'ProPlus2021Volume';  $Channel = 'PerpetualVL2021' }
        }

        $lines = @()
        $lines += '<Configuration>'
        $lines += ('  <Add OfficeClientEdition="{0}" Channel="{1}">' -f $Bitness, $Channel)
        $lines += ('    <Product ID="{0}">' -f $ProductId)
        $lines += ('      <Language ID="{0}" />' -f $Language)
        $lines += '      <ExcludeApp ID="Groove" />'
        $lines += '      <ExcludeApp ID="Lync" />'
        $lines += '    </Product>'
        if ($Channel -eq 'Current') {
            $lines += '    <Product ID="ProofingTools">'
            $lines += ('      <Language ID="{0}" />' -f $Language)
            $lines += '      <ExcludeApp ID="Groove" />'
            $lines += '      <ExcludeApp ID="Lync" />'
            $lines += '    </Product>'
        }
        $lines += '  </Add>'
        $lines += '  <Property Name="SharedComputerLicensing" Value="0" />'
        $lines += '  <Property Name="PinIconsToTaskbar" Value="TRUE" />'
        $lines += '  <Property Name="SCLCacheOverride" Value="0" />'
        $lines += '  <Property Name="AUTOACTIVATE" Value="1" />'
        $lines += '  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />'
        $lines += '  <Property Name="DeviceBasedLicensing" Value="0" />'
        $lines += '  <Updates Enabled="TRUE" />'
        $lines += '  <Display Level="None" AcceptEULA="TRUE" />'
        $lines += '  <Logging Level="Standard" />'
        $lines += '</Configuration>'
        $xmlText = $lines -join [Environment]::NewLine

        New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
        $ConfigPath = Join-Path $TempDir 'config.xml'
        [IO.File]::WriteAllText($ConfigPath, $xmlText, [Text.Encoding]::UTF8)
        $ProductLabel = '{0}（{1}，{2}，{3} 位）' -f $ProductId, $Channel, $Language, $Bitness
    }

    Write-Host ('安装内容：' + $ProductLabel) -ForegroundColor Gray

    # ---------- 下载最新 ODT ----------
    Write-Host ''
    Write-Host '[1/3] 正在从微软下载最新 ODT setup.exe ...'
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
    Remove-Item -LiteralPath $SetupExe -Force -ErrorAction SilentlyContinue
    $oldProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    $downloaded = $false
    for ($i = 1; $i -le 3; $i++) {
        try {
            Invoke-WebRequest -Uri $SetupUrl -OutFile $SetupExe -UseBasicParsing -TimeoutSec 180
            if (Test-Path -LiteralPath $SetupExe) { $downloaded = $true; break }
        } catch {
            Write-Host ('   第 {0} 次下载失败：{1}' -f $i, $_.Exception.Message) -ForegroundColor DarkYellow
            Start-Sleep -Seconds 2
        }
    }
    $ProgressPreference = $oldProgress
    if (-not $downloaded) {
        throw 'setup.exe 下载失败（已重试 3 次）。若国内网络不稳，可先设置环境变量 ODT_SETUP_URL 指向可用下载源。'
    }
    Write-Host '   下载完成。' -ForegroundColor Green

    # ---------- 安装 ----------
    Write-Host ''
    Write-Host '[2/3] 正在安装，Office 会从微软拉取目标通道的最新安装包，请勿关闭窗口...'
    & $SetupExe '/configure' $ConfigPath | Out-Host
    Write-Host ('   setup.exe 退出码：{0}' -f $LASTEXITCODE) -ForegroundColor DarkGray

    # ---------- 结果 ----------
    Write-Host ''
    Write-Host '[3/3] 安装流程结束，本机 Office 状态：'
    $regKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration'
    )
    $found = $false
    foreach ($k in $regKeys) {
        try {
            $props = Get-ItemProperty -Path $k -ErrorAction Stop
            Write-Host ('   产品：{0}' -f $props.ProductReleaseIds)
            Write-Host ('   版本：{0}' -f $props.VersionToReport)
            if ($props.Platform) { Write-Host ('   位数：{0}' -f $props.Platform) }
            if ($props.CDNBaseUrl) { Write-Host ('   通道：{0}' -f $props.CDNBaseUrl) }
            $found = $true
            break
        } catch { }
    }
    if (-not $found) {
        Write-Host '   暂未读到 Click-to-Run 配置：可能仍在安装中或安装失败，请稍后重新运行本脚本查看。' -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host '完成。首次启动 Office 时登录 Microsoft 365 账号或输入产品密钥即可完成授权。' -ForegroundColor Green
    if ($LogPath) { Write-Host ('日志：' + $LogPath) -ForegroundColor DarkGray }
} catch {
    $exitCode = 1
    Write-Host ''
    Write-Host ('安装失败：' + $_.Exception.Message) -ForegroundColor Red
} finally {
    Remove-Item -LiteralPath $SetupExe -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath (Join-Path $TempDir 'config.xml') -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $TempDir -Force -Recurse -ErrorAction SilentlyContinue
    try { Stop-Transcript | Out-Null } catch { }
}

Start-Sleep -Seconds 8
exit $exitCode
