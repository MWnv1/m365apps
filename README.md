**[⬇️ 直接下载 ZIP](https://github.com/MWnv1/m365apps/archive/refs/heads/main.zip)**　·　**[打开仓库主页](https://github.com/MWnv1/m365apps)**　·　解压后双击 `一键安装PS.cmd`，完事

---

# Office ODT 安装器（简体中文）

> 本仓库是 [ivancarlosti/m365apps](https://github.com/ivancarlosti/m365apps) 的 fork，做了简体中文与国内使用场景的改造。上游采用 MIT 许可，原版权归 ivancarlosti。

[![License](https://img.shields.io/github/license/MWnv1/m365apps?label=License)](LICENSE)

## 三种用法，选一个

| 方式 | 入口 | 适合谁 |
| :--- | :--- | :--- |
| 全自动（推荐） | 双击 `一键安装PS.cmd` | 什么都不想选，就想装好 |
| 快捷批处理 | 双击 `一键安装.cmd` | 不想用 PowerShell，想拖个 XML 进去 |
| 菜单交互 | 右键 `office-odt-cn.bat` → 以管理员运行 | 要选产品 / 只卸 Project+Visio / 改注册表开关 |

## 全自动 PowerShell 版（`install.ps1`）

双击 `一键安装PS.cmd` 后，你**只需要在 UAC 弹窗里点一次“是”**，往后全部自动：

1. 自检权限，不够就自己弹 UAC 提权，并以相同参数重启自己
2. 删掉上次残留的 `setup.exe`，**重新从微软拉最新 ODT**
3. 根据参数实时生成 `configuration.xml`（不再依赖静态文件）
4. `setup.exe /configure` 静默安装，**ODT 自己去 CDN 拉目标通道当前最新版本**
5. 读 `ClickToRun\Configuration` 打印产品 ID / 版本 / 位数 / 通道
6. 清理临时文件、全程写日志，窗口 8 秒后自动关闭

默认装 **微软 365 企业版 · 简体中文 · 64 位 · Current 通道**。换产品、换语言、换位数都不用改代码：

```powershell
# 在 cmd 里，或双击前建个快捷方式把参数追在后面
powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1 -Product Business
```

| 参数 | 可选值 | 默认 |
| :--- | :--- | :--- |
| `-Product` | `Enterprise` / `Business` / `Home` / `LTSC2024` / `LTSC2021` | `Enterprise` |
| `-Language` | `zh-CN` / `en-US` | `zh-CN` |
| `-Bitness` | `64` / `32` | `64` |
| `-Config` | 任意 XML 路径（给了它就忽略上面三个） | 无 |

也可以直接 `一键安装PS.cmd -Product LTSC2024`，启动器会把参数透传给 ps1。

> 为什么还要个 `.cmd` 启动器？Windows 里双击 `.ps1` 只会用编辑器打开它（不执行），而且默认执行策略会拦下未签名脚本。启动器用 `-ExecutionPolicy Bypass` 拉起，并在拉起前对你的 `install.ps1` 做一次 `Unblock-File`，所以双击就能直接跑。

日志落在脚本同目录：`install-log-<时间戳>.txt`，装完除了 8 秒等待不会停在任何提示上。

## 快捷批处理版（`一键安装.cmd` / `一键卸载.cmd`）

| 文件 | 作用 |
| :-: | :--- |
| `一键安装.cmd` | 双击 → 提权 → 下载官方 ODT → 按预设 XML 安装 → 结束后打印已装产品 |
| `一键卸载.cmd` | 双击 → 先结束残留 Office 进程 → 卸载全部 Office |

装什么改顶部一行：`set "XML=XMLFiles/InstallOffice-Enterprise-CN.xml"`；也可以把任意 `.xml` 拖到它上面。

## 菜单版（`office-odt-cn.bat`）

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

**卸载**：`9` 卸全部、`0` 只卸 Project / Visio。

**工具**：`A` 查看已装产品 / `B`~`D` OneDrive 个人版同步开关 / `E`~`G` 预览体验按钮开关 / `H` 清更新通道策略 / `Q` 退出。

## 这个脚本是什么

一个调用**微软官方 Office Deployment Tool（ODT）**来安装、更新、卸载微软 Office 的工具集，提供三种入口（自动 / 快捷 / 菜单）。它不自己维护 Office 安装包，而是每次运行时从 Microsoft CDN 下载最新签名过的 `setup.exe`，再由它拉取目标通道的最新版本，因此你装到的总是当前最新构建。

## 免责声明

- 本仓库**不包含**任何 KMS 模拟、激活绕过、破解或密钥生成代码，也不提供任何形式的“免费激活”。
- 安装的 Office 需要你自己持有合法授权：零售版密钥、Microsoft 365 订阅，或组织提供的批量许可（MAK / KMS）。
- 仅建议用于你自己的设备或你有权部署的设备。

## 目录结构

```
一键安装PS.cmd              PowerShell 启动器（推荐，双击即装）
install.ps1                 全自动安装引擎（自提权 / 自拉最新 / 自生成 XML / 写日志）
一键安装.cmd                 批处理一键直装（默认 365 企业版简中）
一键卸载.cmd                 批处理一键卸载
office-odt-cn.bat            中文菜单（选产品 / 卸载范围 / 注册表开关）
m365apps.bat                 上游原版入口（保留未动）
XMLFiles/                    静态 XML 配置（产品 / 语言 / 仅卸 Project+Visio）
README.md                    中文说明
README.en.md                 英文说明 / 上游文档入口
LICENSE                      MIT
```

## 与上游的差异

1. **新增 PowerShell 全自动入口** `install.ps1`：自提权、自拉最新 ODT、运行时生成 XML、写日志、零提问。
2. **新增批处理一键直装 / 直卸** `一键安装.cmd`、`一键卸载.cmd`，支持把 XML 拖到脚本上。
3. **新增中文菜单** `office-odt-cn.bat`，上游 `m365apps.bat` 原样保留可对照。
4. **新增 zh-CN 配置**，并额外提供 **Office LTSC 2024 / 2021** 两条通道（`PerpetualVL2024` / `PerpetualVL2021`）。
5. **下载鲁棒性**：批处理版 curl 缺失时回退 PowerShell；ps1 自带 3 次重试；两者都支持 `ODT_SETUP_URL` 覆盖下载源。
6. **修掉上游的菜单匹配隐患**：原版 `if "%op%"=="1" set ... & set ...` 中 `&` 会让后半句无论条件是否成立都执行，可能导致选错 XML；本版改为括号块 + `goto`。
7. **新增仅卸载 Project / Visio** 的配置与入口。

## 常见调整

| 需求 | 改哪里 |
| :--- | :--- |
| 换全自动安装的产品 | 双击时带参数：`一键安装PS.cmd -Product Business` / `-Product LTSC2024` |
| 装 32 位 | `-Bitness 32`，或改 XML 里 `OfficeClientEdition="64"` 为 `32` |
| 换语言 | `-Language en-US`，或改 XML 里 `Language ID` |
| 不装某个组件 | XML 的 `<Product>` 里加 `<ExcludeApp ID="Access" />`（可选 Outlook / Publisher / OneNote / Groove=OneDrive / Lync=Skype） |
| 换更新通道 | `Channel` 改 `MonthlyEnterprise` / `SemiAnnual` / `Beta` |
| 国内下载慢 | 先设 `ODT_SETUP_URL` 指向可用源 |

> 只装 Access / Publisher 这类单个应用不是 ODT 的能力范围（ODT 按产品卷部署），需要时请在已装 Office 上通过“应用”列表管理。

## 常见问题

- **双击就被拦 / 提示“已保护你的电脑”**：解压出的文件带了“来自网络”标记。右键文件 → 属性 → 底部「解除锁定」，或 PowerShell 里 `Unblock-File .\一键安装PS.cmd`。
- **“找不到配置文件”**：别把脚本单独拷出来，`XMLFiles/` 要与脚本同级。
- **装完没激活**：本仓库不处理激活，首次启动 Office 登录 365 账号或输入零售/批量密钥即可。
- **想确认版本**：重跑 `install.ps1` 或在菜单里按 `A`，会打印产品 ID 与版本号。

## 许可与致谢

MIT License，见 [LICENSE](LICENSE)。

- 原始代码与文档：© ivancarlosti（[原仓库](https://github.com/ivancarlosti/m365apps)）
- 中文定制部分：© MWnv1

按 MIT 要求，原版权声明与许可声明已保留。
