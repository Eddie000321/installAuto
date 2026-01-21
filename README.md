# SiSoftware Sandra Auto-Reinstall System

Automated tools for reinstalling **SiSoftware Sandra Lite** on Windows systems. Choose the version that fits your deployment needs.

---

## 📦 Two Versions Available

| Version | Folder | Best For |
|---------|--------|----------|
| **USB Version** | `USB-Version/` | One-time manual reinstall, troubleshooting |
| **Scheduler Version** | `windowSchedule-Version/` | Automatic 30-day cycle, set-and-forget |

---

## 🔌 USB Version

**Manual execution** — Run the script each time you need to reinstall.

```
USB-Version/
├── auto_production.bat   ← Fully automatic (recommended)
├── auto.bat              ← Debug mode with pauses
└── san31137.exe          ← Installer (add this)
```

### How to Use:
1. Copy files to USB
2. Plug into target PC
3. Run `auto_production.bat` as administrator
4. Wait ~60 seconds → Done!

📖 [View USB Version README](USB-Version/README.md)

---

## ⏰ Windows Scheduler Version

**Automatic execution** — Set up once, computer handles reinstalls every 30 days.

```
windowSchedule-Version/
├── 0_Setup.bat           ← One-time setup script
├── Logic.ps1             ← 30-day check logic (brain)
└── san31137.exe          ← Installer (add this)
```

### How to Use:
1. Copy files to USB
2. Plug into target PC
3. Run `0_Setup.bat` as administrator (~3 seconds)
4. Done! PC will auto-reinstall every 30 days

📖 [View Scheduler Version README](windowSchedule-Version/README.md)

---

## 🆚 Comparison

| Feature | USB Version | Scheduler Version |
|---------|-------------|-------------------|
| Setup time | N/A | ~3 sec per PC |
| Execution | Manual each time | Automatic at boot |
| Frequency | When you run it | Every 30 days |
| User interaction | Required | None after setup |
| Files on PC | None | `C:\Sandra_Auto\` |
| Best for | Quick fixes | 120+ PC deployment |

---

## 🛡️ Safety

Both versions are **completely safe**:

- ✅ Only affects Sandra software
- ✅ Uses official Windows commands
- ✅ No registry modifications (beyond normal install/uninstall)
- ✅ No data collection or external connections
- ✅ No system restarts

---

## 📋 Quick Start Guide

### For Single PC / Troubleshooting:
→ Use **USB Version**

### For 120+ PCs / Automated Lab Management:
→ Use **Scheduler Version**

---

## 🐛 Report Issues

If either version has problems, please report:
- Which version (USB or Scheduler)
- Which step failed
- Error message or screenshot
- Windows version
