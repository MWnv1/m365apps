# Microsoft Office ODT Installer (Chinese-localized fork)

This repository is a fork of [ivancarlosti/m365apps](https://github.com/ivancarlosti/m365apps) (MIT).

**What changed in this fork**

- New Chinese interactive menu: `office-odt-cn.bat`. The upstream `m365apps.bat` is left untouched for reference.
- New `zh-CN` XML profiles, plus Office LTSC 2024 (`PerpetualVL2024`) and LTSC 2021 (`PerpetualVL2021`) profiles.
- New menu entry to read the installed Office product ID / version / platform / update channel from `HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration`.
- Download fallback: if `curl.exe` is unavailable, PowerShell `Invoke-WebRequest` is used. `ODT_SETUP_URL` env var overrides the setup.exe source.
- Fixed an upstream menu-matching hazard: `if "%op%"=="1" set A=... & set B=...` executes the part after `&` unconditionally; this fork uses parentheses plus `goto`.
- Added an uninstall profile for Project / Visio only.

For the full original English documentation (menu layout, how ODT is bootstrapped, tweak registry keys), see the upstream repository:
**https://github.com/ivancarlosti/m365apps**

## Scope and disclaimer

This script only drives Microsoft's official Office Deployment Tool. It contains **no activation, KMS emulation, cracking or key-generation code**. You must hold a valid license (retail key, Microsoft 365 subscription, or organizational MAK/KMS) for the Office you install. Use it only on devices you own or are authorized to deploy.

## Quick start

1. Download or clone this repo.
2. Right-click `office-odt-cn.bat` → **Run as administrator**.
3. Pick a menu entry.

Windows 10 1803+ / Windows 11 required.

## License

MIT, see [LICENSE](LICENSE). Original code © ivancarlosti; localized additions © MWnv1. The original copyright and permission notice are retained as required by the MIT license.
