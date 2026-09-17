# Security Audit Report

## Summary

This repository contains Roblox Lua exploit scripts. A security scan identified several categories of vulnerabilities.

## Critical Issues (Fixed)

### 1. Arbitrary Code Execution via Pastebin (`G&B` line 794)
**Severity: CRITICAL**

The script loaded and executed code from `https://pastebin.com/raw/eDeT31nb`. Pastebin content can be modified by the paste owner at any time, meaning this is effectively a backdoor — anyone controlling that paste can inject arbitrary code into all users running this script.

**Fix:** Replaced with an inline FPS boost implementation.

### 2. Obfuscated/Unauditable Code (`EXPLODEBULLETEBO`, `ARKUILIMITED`)
**Severity: CRITICAL**

Two files contained heavily obfuscated code from `wearedevs.net/obfuscator`. Obfuscated code cannot be audited for malicious behavior (keyloggers, data exfiltration, backdoors). These are opaque blobs that could do anything.

**Fix:** Removed both files from the repository.

### 3. Untrusted Third-Party Script Loading (`G&B`, `Slab Battles`)
**Severity: HIGH**

- `G&B`: Loaded code from `dyumra/dyumrascript-` (unverified third-party repo)
- `Slab Battles`: Loaded code from `ionlyusegithubformcmods/1-Line-Scripts` (unverified)

**Fix:** Replaced with inline implementations or pinned to auditable official sources.

---

## Remaining Risks (Not Fixed — Require Architectural Decision)

### 4. Remote Code Execution via `loadstring(game:HttpGet(...))` Pattern
**Severity: HIGH | Files: 20+ scripts**

Nearly every script uses `loadstring(game:HttpGet(url))()` to load UI libraries (WindUI, DummyUI, Rayfield) from GitHub. While these are from known repos, they point to `main` branch (not pinned commits), so upstream changes propagate silently.

**Recommendation:** Pin all external URLs to specific commit SHAs:
```lua
-- Instead of:
loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
-- Use:
loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/<COMMIT_SHA>/dist/main.lua"))()
```

### 5. Filesystem Read/Write Without Path Validation
**Severity: MEDIUM | Files: AutoGya, KajiriGya, KA, KAALT**

Scripts use `writefile`/`readfile` with hardcoded filenames (e.g., `"ArkHub_SavedConfig.json"`). While not directly exploitable in the Roblox executor sandbox, a malicious config file could cause JSON parsing issues or unexpected behavior.

**Recommendation:** Validate JSON structure after `JSONDecode` before merging into Config.

### 6. Anti-Cheat Bypass via Metatable Hooking
**Severity: MEDIUM | Files: KA, BLR:ArkHub, Mm2, Flick, Kimui, Buttons, Inkgame, Slab Battles**

Scripts hook `__namecall` and `__index` metatables to intercept and suppress security-related remote calls. While intentional for the scripts' purpose, this pattern can be detected and may result in account bans.

### 7. Unvalidated Remote Server Data
**Severity: MEDIUM | Files: AutoBl, AutoGya, KajiriGya, BLR:ArkHub, KA**

Scripts fetch server lists from `games.roblox.com` API and use the response data (server IDs, player counts) without validation. A MITM or DNS poisoning attack could inject malicious server IDs.

### 8. Hardcoded Discord Invite Links
**Severity: LOW | Files: DEADRAILS, Kimui, Inkgame**

Discord invite links are hardcoded. These expose community infrastructure and could be used for social engineering if the linked servers are compromised.

---

## Recommendations

1. **Never use `loadstring` with `pastebin.com` or unknown sources** — content can change without notice
2. **Never commit obfuscated code** — if you can't read it, you can't trust it
3. **Pin all GitHub raw URLs to specific commit SHAs** rather than branch names
4. **Validate all external data** (JSON responses, server lists) before use
5. **Consider vendoring UI libraries** (WindUI, DummyUI) locally instead of fetching at runtime
