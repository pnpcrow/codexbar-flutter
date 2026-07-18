# CodexBar Upstream Change Tracker

## Baseline Checkpoint
- **Date**: 2026-07-18
- **Commit**: `59c081332066710d555d5b56c2948b0784cfa316`
- **Version**: 0.43.1 (build 105)
- **Branch**: main

## How to Use This Tracker

### Detecting Changes
```bash
# 원본 프로젝트의 변경 사항 확인
git log --oneline 59c08133..HEAD -- Sources/CodexBarCore/Providers/
git log --oneline 59c08133..HEAD -- Sources/CodexBar/
git diff --stat 59c08133..HEAD -- Sources/CodexBarCore/
```

### Change Log Format
각 업데이트 항목은 다음 형식으로 기록합니다:
```
### [날짜] commit_hash
- **Type**: [Provider Addition|Provider Update|Core Model|UI|Auth|Config]
- **Summary**: 변경 요약
- **Affected Providers**: 영향받은 프로바이더 목록
- **Files Changed**: 변경된 파일 목록
- **Porting Action Required**: 포팅 필요 작업
- **Status**: [Pending|In Progress|Done|N/A]
```

---

## Change Log

### [2026-07-18] Initial Checkpoint
- **Type**: Baseline
- **Summary**: Flutter 포팅 시작 시점의 CodexBar 스냅샷
- **Version**: 0.43.1 (build 105)
- **Commit**: `59c081332066710d555d5b56c2948b0784cfa316`
- **Total Providers**: 60
- **Status**: Baseline established

---

## Provider-Specific Tracking

각 프로바이더의 포팅 상태를 추적합니다:

| Provider | Swift Status | Flutter Status | Last Synced | Notes |
|----------|-------------|----------------|-------------|-------|
| codex | Implemented | Not Started | 2026-07-18 | |
| openai | Implemented | Not Started | 2026-07-18 | |
| azureopenai | Implemented | Not Started | 2026-07-18 | |
| claude | Implemented | Not Started | 2026-07-18 | |
| cursor | Implemented | Not Started | 2026-07-18 | |
| opencode | Implemented | Not Started | 2026-07-18 | |
| opencodego | Implemented | Not Started | 2026-07-18 | |
| alibaba | Implemented | Not Started | 2026-07-18 | |
| alibabatokenplan | Implemented | Not Started | 2026-07-18 | |
| factory | Implemented | Not Started | 2026-07-18 | |
| gemini | Implemented | Not Started | 2026-07-18 | |
| antigravity | Implemented | Not Started | 2026-07-18 | |
| copilot | Implemented | Not Started | 2026-07-18 | |
| devin | Implemented | Not Started | 2026-07-18 | |
| zai | Implemented | Not Started | 2026-07-18 | |
| minimax | Implemented | Not Started | 2026-07-18 | |
| manus | Implemented | Not Started | 2026-07-18 | |
| kimi | Implemented | Not Started | 2026-07-18 | |
| kilo | Implemented | Not Started | 2026-07-18 | |
| kiro | Implemented | Not Started | 2026-07-18 | |
| vertexai | Implemented | Not Started | 2026-07-18 | |
| augment | Implemented | Not Started | 2026-07-18 | |
| jetbrains | Implemented | Not Started | 2026-07-18 | |
| kimik2 | Implemented | Not Started | 2026-07-18 | |
| moonshot | Implemented | Not Started | 2026-07-18 | |
| amp | Implemented | Not Started | 2026-07-18 | |
| t3chat | Implemented | Not Started | 2026-07-18 | |
| ollama | Implemented | Not Started | 2026-07-18 | |
| synthetic | Implemented | Not Started | 2026-07-18 | |
| warp | Implemented | Not Started | 2026-07-18 | |
| openrouter | Implemented | Not Started | 2026-07-18 | |
| elevenlabs | Implemented | Not Started | 2026-07-18 | |
| windsurf | Implemented | Not Started | 2026-07-18 | |
| zed | Implemented | Not Started | 2026-07-18 | |
| perplexity | Implemented | Not Started | 2026-07-18 | |
| mimo | Implemented | Not Started | 2026-07-18 | |
| doubao | Implemented | Not Started | 2026-07-18 | |
| sakana | Implemented | Not Started | 2026-07-18 | |
| abacus | Implemented | Not Started | 2026-07-18 | |
| mistral | Implemented | Not Started | 2026-07-18 | |
| deepseek | Implemented | Not Started | 2026-07-18 | |
| codebuff | Implemented | Not Started | 2026-07-18 | |
| crof | Implemented | Not Started | 2026-07-18 | |
| venice | Implemented | Not Started | 2026-07-18 | |
| commandcode | Implemented | Not Started | 2026-07-18 | |
| qoder | Implemented | Not Started | 2026-07-18 | |
| stepfun | Implemented | Not Started | 2026-07-18 | |
| bedrock | Implemented | Not Started | 2026-07-18 | |
| grok | Implemented | Not Started | 2026-07-18 | |
| groq | Implemented | Not Started | 2026-07-18 | |
| llmproxy | Implemented | Not Started | 2026-07-18 | |
| litellm | Implemented | Not Started | 2026-07-18 | |
| deepgram | Implemented | Not Started | 2026-07-18 | |
| poe | Implemented | Not Started | 2026-07-18 | |
| chutes | Implemented | Not Started | 2026-07-18 | |
| crossmodel | Implemented | Not Started | 2026-07-18 | |
| clawrouter | Implemented | Not Started | 2026-07-18 | |
| sub2api | Implemented | Not Started | 2026-07-18 | |
| wayfinder | Implemented | Not Started | 2026-07-18 | |
| zenmux | Implemented | Not Started | 2026-07-18 | |

---

## Core Module Tracking

| Module | Swift Files | Flutter Status | Last Synced |
|--------|-------------|----------------|-------------|
| Provider System | Providers.swift, ProviderDescriptor.swift, ProviderFetchPlan.swift | Not Started | 2026-07-18 |
| Usage Models | UsageFetcher.swift, CreditsModels.swift | Not Started | 2026-07-18 |
| Auth System | BrowserCookieAccessGate.swift, KeychainAccessGate.swift, ProviderTokenResolver.swift | Not Started | 2026-07-18 |
| Settings | SettingsStore.swift, Config/ | Not Started | 2026-07-18 |
| Notifications | AppNotifications.swift, SessionQuotaNotifications.swift | Not Started | 2026-07-18 |
| UI - Menu | MenuCardView.swift, StatusItemController.swift | Not Started | 2026-07-18 |
| UI - Settings | PreferencesView.swift, Preferences*.swift | Not Started | 2026-07-18 |
| UI - Charts | CostHistoryChartMenuView.swift, CreditsHistoryChartMenuView.swift | Not Started | 2026-07-18 |
| Icon | IconRenderer.swift, IconRemainingResolver.swift | Not Started | 2026-07-18 |
