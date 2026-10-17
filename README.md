# DevControl Next — Public Binary Distribution

This is a **public distribution-only repository**. Private DevControl Next source and production DevControl 3 data are **not** published here.

**Release status: `v0.1.0-preview.1` — experimental QA artifacts, not a working hosted remote MCP product yet.** The future Gateway `https://mcpx.devcontrol.dev` and Auth `https://authx.devcontrol.dev` are not publicly deployed. Installing these packages does not enable device enrollment or AI control until that independent backend is complete.

## One-command, user-scoped preview installation

**Windows PowerShell 5.1+** (unsigned preview package, separate from original Agent):

```powershell
irm https://raw.githubusercontent.com/star8592/DevControl-Next-Downloads/main/install.ps1 | iex
```

**Linux x86_64** (no sudo, Docker or Node.js required):

```bash
curl -fsSL https://raw.githubusercontent.com/star8592/DevControl-Next-Downloads/main/install.sh | bash
```

**Android** (USB debugging + adb on Linux/macOS):

```bash
curl -fsSL https://raw.githubusercontent.com/star8592/DevControl-Next-Downloads/main/install-android.sh | bash
```

Alternatively, download the APK in GitHub Releases and install it on the Android device. ADB installs a separate app `dev.devcontrol.next.agent`, not the old Agent.

## Direct downloads

The fixed prerelease [download page](https://github.com/star8592/DevControl-Next-Downloads/releases/tag/v0.1.0-preview.1) includes Windows ZIP, Android APK, Linux tarball and **individual SHA-256 files**. All are publicly available over GitHub HTTPS without a GitHub account.

Never install these QA binaries on production control devices. Windows preview uses an unsigned executable (Windows security warnings are expected). Android preview uses a debug signing key. For production, stable trusted signing, two-Agent coexistence, durable multi-tenant OAuth/Gateway and end-to-end remote control evidence remain required.

These files must never reuse `mcp.devcontrol.dev`, `auth.devcontrol.dev`, original DevControl Agent credentials or its install directories.
