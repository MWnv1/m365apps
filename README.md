**[⬇️ 直接下载 ZIP](https://github.com/MWnv1/m365apps/archive/refs/heads/main.zip)**　·　**[打开仓库主页](https://github.com/MWnv1/m365apps)**　·　解压后直接双击 `一键安装.cmd` 即可

---

# Office ODT 安装器（简体中文）

> 本仓库是 [ivancarlosti/m365apps](https://github.com/ivancarlosti/m365apps) 的 fork，做了简体中文与国内使用场景的改造。上游采用 MIT 许可，原版权归 ivancarlosti。

[![License](https://img.shields.io/github/license/MWnv1/m365apps?label=License)](LICENSE)

## 一键安装（双击即装）

不想看菜单？双击这两个文件就行：

| 文件 | 作用 |
| :-: | :--- |
| `一键安装.cmd` | 双击 → 自动提权 → 下载官方 ODT → 按预设 XML 静默安装 → 结束后打印已装产品 |
| `一键卸载.cmd` | 双击 → 先结束残留 Office 进程 → 卸载全部 Office |

默认装的是 **微软 365 企业版（简体中文 64 位）**。要换产品，改 `一键安装.cmd` 顶部这一行即可：

```bat
set "XML=XMLFiles/InstallOffice-Enterprise-CN.xml"
```

也可以直接把任意 `.xml` 拖到 `一键安装.cmd` 上，它会用你拖的那个配置（拖放时仍会自动提权）。

> 首次启动 Office 时登录 365 账号或输入产品密钥完成授权，脚本不参与授权环节。

## 这个脚本是什么

一个菜单式的 Windows 脚本，全程调用**微软官方 Office Deployment Tool（ODT）**来安装、卸载微软 Office。它在运行时从 Microsoft CDN 下载最新签名过的 `setup.exe`，再用仓库内的 XML 配置驱动它，因此不需要你手写或校验 XML。

## 免责声明

- 本脚本**不包含**任何 KMS 模拟、激活绕过、破解或密钥生成代码，也不提供任何形式的“免费激活”。
- 安装的 Office 需要你自己持有合法授权：零售版密钥、Microsoft 365 订阅，或组织提供的批量许可（MAK / KMS）。
- 仅建议用于你自己的设备或你有权部署的设备。

## 菜单（备选）

需要选产品、选卸载范围、或开注册表开关时用 `office-odt-cn.bat`。

**安装**

| 按键 | 内容 |
| :-: | :--- |
| 1 | 微软 365 商业版 + Project + Visio（简中） |
| 2 | 微软 365 商业版（简中） |
| 3 | 微软 365 企业版 + Project + Visio（简中） |
| 4 | 微软 365 企业版（简中） |
| 5 | 微软 365 家庭版（简中） |
| 6 | Office LTSC 2024 专业增强版（简中，需批量许可） |
| 7 | Office LTSC 2021 专业增强版（简中，需批量许可） |
| 8 | 自定义配置（读 `XMLFiles/my-config.xml`） |

**卸载**

| 按键 | 内容 |
| :-: | :--- |
| 9 | 卸载全部 Office 产品 |
| 0 | 仅卸载 Project / Visio |

**工具**

| 按键 | 内容 |
| :-: | :--- |
| A | 查看已装产品的 ID / 版本 / 位数 / 更新通道 |
| B | 允许 OneDrive 个人版同步 |
| C | 禁用 OneDrive 个人版同步 |
| D | 移除 OneDrive 个人版同步策略 |
| E | 显示 Office 预览体验按钮 |
| F | 隐藏 Office 预览体验按钮 |
| G | 移除 Office 预览体验策略 |
| H | 移除 Office 更新通道策略 |
| Q | 退出 |

## 用法

1. 点顶部链接下载 ZIP，或 `git clone https://github.com/MWnv1/m365apps.git`。
2. 一键装：双击 `一键安装.cmd`；要选产品：右键 `office-odt-cn.bat` → **以管理员身份运行**。
3. 安装前先关掉所有 Office 程序。

> 仅支持 Windows 10 1803 以上 / Windows 11。两个入口都会在需要时自动弹 UAC 提权。

## 目录结构

```
一键安装.cmd                 双击即装（默认 365 企业版简中）
一键卸载.cmd                 双击即卸全部 Office
office-odt-cn.bat            中文菜单入口（可任选产品 / 卸载范围 / 注册表开关）
m365apps.bat                 上游原版入口（保留未动）
XMLFiles/
  InstallOffice-Business-CN.xml
  InstallOfficeProjectVisio-Business-CN.xml
  InstallOffice-Enterprise-CN.xml
  InstallOfficeProjectVisio-Enterprise-CN.xml
  InstallOffice-Home-CN.xml
  InstallOffice-LTSC2024-CN.xml
  InstallOffice-LTSC2021-CN.xml
  UninstallOffice.xml
  UninstallProjectVisio.xml
  my-config.xml.example
README.md                    中文说明
README.en.md                 英文说明 / 上游文档入口
LICENSE                      MIT
```

## 与上游的差异

1. **新增一键直装 / 直卸脚本** `一键安装.cmd`、`一键卸载.cmd`，无需菜单，支持把 XML 拖到脚本上换配置。
2. **新增中文菜单** `office-odt-cn.bat`，上游 `m365apps.bat` 原样保留，可随时对照。
3. **新增 zh-CN 配置**，并额外提供 **Office LTSC 2024 / 2021** 两条通道（`PerpetualVL2024` / `PerpetualVL2021`）。
4. **新增“查看已安装 Office”选项**，直接读 `ClickToRun\Configuration` 注册表，不动其他配置。
5. **下载鲁棒性**：`curl.exe` 不存在时自动回退到 PowerShell 下载；可用环境变量 `ODT_SETUP_URL` 覆盖下载源。
6. **修掉上游的菜单匹配隐患**：原版的 `if "%op%"=="1" set ... & set ...` 中 `&` 会让后半句无论条件是否成立都执行，可能导致选错 XML；本版改为括号块 + `goto`。
7. **新增仅卸载 Project / Visio** 的配置与入口。

## 常见调整

| 需求 | 改哪里 |
| :--- | :--- |
| 换一键安装的产品 | `一键安装.cmd` 顶部的 `set "XML=..."` 一行 |
| 装 32 位 | XML 里 `OfficeClientEdition="64"` 改为 `32` |
| 换语言 | XML 里 `Language ID="zh-cn"` 改为 `en-us` 等 |
| 不装某个组件 | 在 `<Product>` 里加 `<ExcludeApp ID="Access" />`（可选 Outlook / Publisher / OneNote / Groove=OneDrive / Lync=Skype） |
| 想看详细日志 | `Logging Level="Off"` 改为 `Standard`，并加 `Path="C:\ODTLog"` |
| 换更新通道 | `Channel="Current"` 改为 `MonthlyEnterprise` / `SemiAnnual` / `Beta` |

> 只装 Access / Publisher 这类单个应用不是 ODT 的能力范围（ODT 按产品卷部署），需要时请在已装 Office 上通过“应用”列表管理。

## 许可与致谢

MIT License，见 [LICENSE](LICENSE)。

- 原始代码与文档：© ivancarlosti（[原仓库](https://github.com/ivancarlosti/m365apps)）
- 中文定制部分：© MWnv1

按 MIT 要求，原版权声明与许可声明已保留。
