# CodexBar Flutter Porting Guide

## 1. Project Overview

### 1.1 Purpose
CodexBar는 macOS 메뉴 바 앱으로, 60개 이상의 AI 코딩 프로바이더의 사용량/크레딧/한도를 모니터링합니다.
Swift/SwiftUI/AppKit 기반의 원본을 Flutter Desktop으로 포팅합니다.

### 1.2 Core Requirements
- **시스템 트레이**: macOS/Linux/Windows 시스템 트레이에 아이콘 표시, 메인 윈도우 표시/숨김
- **프로바이더 지원**: 원본 CodexBar의 모든 60개 프로바이더 동일 지원
- **인증 전략**: CLI 토큰 우선 → 브라우저 쿠키 폴백 → 둘 다 있으면 경쟁(race) 후 빠른 쪽 사용, 실패시 다음으로 폴백
- **사용량 변경 알림**: 이전 스냅샷과 현재 스냅샷 비교, 변경시 시스템 알림 (옵션)
- **UI/기능 동일 유지**: 원본의 화면 구성, 메뉴 구조, 차트, 설정 등을 그대로 유지

### 1.3 Branch
- Branch: `flutter-port-mimo`
- Base commit: `59c081332066710d555d5b56c2948b0784cfa316`
- CodexBar version: `0.43.1` (build 105)
- Checkpoint date: 2026-07-18

---

## 2. CodexBar Architecture (Swift Original)

### 2.1 Layer Structure
```
┌─────────────────────────────────────────────┐
│  CodexBar (App Layer)                       │
│  - StatusItemController (메뉴 바 아이콘)     │
│  - MenuCardView (사용량 표시 UI)             │
│  - PreferencesView (설정 UI)                 │
│  - SettingsStore (사용자 설정)               │
│  - UsageStore (사용량 데이터 저장/갱신)       │
│  - IconRenderer (아이콘 렌더링)              │
│  - AppNotifications (알림 시스템)            │
│  - Providers/ (프로바이더별 UI 확장)         │
├─────────────────────────────────────────────┤
│  CodexBarCore (Core Layer)                  │
│  - Providers/ (프로바이더 프로토콜/구현)     │
│  - UsageFetcher (데이터 페칭)               │
│  - ProviderFetchPlan (페칭 전략)             │
│  - ProviderDescriptor (프로바이더 메타데이터) │
│  - BrowserCookieAccessGate (쿠키 인증)       │
│  - KeychainAccessGate (키체인 인증)          │
│  - Config/ (설정 구조체)                     │
│  - WebKit/ (웹 기반 페칭)                    │
│  - OpenAIWeb/ (OpenAI 웹 페칭)              │
└─────────────────────────────────────────────┘
```

### 2.2 Provider Protocol Architecture

#### ProviderDescriptor (프로바이더 정의)
```swift
struct ProviderDescriptor {
    let id: UsageProvider          // enum 케이스 (.claude, .openai, 등)
    let metadata: ProviderMetadata // 표시 이름, CLI 이름, 대시보드 URL 등
    let branding: ProviderBranding // 아이콘 스타일, 색상
    let tokenCost: ProviderTokenCostConfig
    let fetchPlan: ProviderFetchPlan // 페칭 전략 파이프라인
    let cli: ProviderCLIConfig      // CLI 이름, 별명, 버전 감지
}
```

#### ProviderFetchStrategy (페칭 전략 프로토콜)
```swift
protocol ProviderFetchStrategy {
    var id: String { get }
    var kind: ProviderFetchKind { get }  // .cli, .web, .oauth, .apiToken, .localProbe
    func isAvailable(_ context: ProviderFetchContext) async -> Bool
    func fetch(_ context: ProviderFetchContext) async throws -> ProviderFetchResult
    func shouldFallback(on error: Error, context: ProviderFetchContext) -> Bool
}
```

#### ProviderFetchPipeline (폴백 체인)
- 프로바이더별로 여러 Strategy를 우선순위 배열로 등록
- 순차 실행: 첫 번째 Strategy가 사용 불가/실패시 다음으로 폴백
- `shouldFallback()`이 true면 계속, false면 에러 반환

#### ProviderSourceMode (소스 모드)
```swift
enum ProviderSourceMode {
    case auto    // CLI 우선, 없으면 웹/쿠키
    case web     // 브라우저 쿠키만
    case cli     // CLI만
    case oauth   // OAuth 인증
    case api     // API 키
}
```

### 2.3 Auth Strategy (인증 전략)
사용자 지시에 따른 우선순위:
1. **CLI/터미널 프로바이더**: `codex`, `claude` 등 CLI 바이너리가 설치되어 있으면 해당 CLI의 인증 정보 사용
2. **브라우저 쿠키**: CLI가 없으면 Chrome/Safari/Firefox 등에서 웹 인증 토큰 추출
3. **Race (경쟁)**: 둘 다 존재하면 먼저 응답하는 쪽을 메인으로 사용
4. **Fallback**: 메인 전략 실패시 다음 빠른 전략으로 자동 전환

원본 구현의 핵심 패턴:
- `ProviderFetchPipeline.resolveStrategies()`가 사용 가능한 전략 목록 반환
- `ProviderCandidateRetryRunner`가 경쟁/재시도 로직 처리
- `BrowserCookieAccessGate`가 브라우저 쿠키 접근 관리
- `ProviderTokenResolver`가 CLI/API 토큰 해석

### 2.4 Data Models

#### UsageSnapshot (사용량 스냅샷)
```swift
struct UsageSnapshot {
    let primary: RateWindow?      // 주 사용량 (예: 세션 한도)
    let secondary: RateWindow?    // 보조 사용량 (예: 주간 한도)
    let tertiary: RateWindow?     // 삼차 사용량 (예: Opus)
    let extraRateWindows: [NamedRateWindow]?
    let providerCost: ProviderCostSnapshot?
    // 프로바이더별 특수 필드 (kiroUsage, ampUsage, zaiUsage, 등)
    let updatedAt: Date
    let identity: ProviderIdentitySnapshot?
    let dataConfidence: UsageDataConfidence
}
```

#### RateWindow (사용량 윈도우)
```swift
struct RateWindow {
    let usedPercent: Double       // 사용률 (0-100)
    let windowMinutes: Int?       // 윈도우 길이 (분)
    let resetsAt: Date?           // 리셋 시간
    let resetDescription: String?
    let nextRegenPercent: Double?
    let isSyntheticPlaceholder: Bool
}
```

#### ProviderIdentitySnapshot (프로바이더 식별)
```swift
struct ProviderIdentitySnapshot {
    let providerID: UsageProvider?
    let accountEmail: String?
    let accountOrganization: String?
    let loginMethod: String?
    let accountID: String?
}
```

### 2.5 SettingsStore (설정 구조)
주요 설정 항목:
- `debugLogLevel`: 로그 레벨
- `enabledProviders`: 활성화된 프로바이더 목록
- `providerSettings`: 프로바이더별 개별 설정 (소스 모드, 쿠키 소스 등)
- `refreshFrequency`: 갱신 주기 (manual/1m/2m/5m/15m/30m/adaptive)
- `menuBarMetricPreference`: 메뉴 바 표시 메트릭
- `confettiOnSessionLimitResetsEnabled`: 세션 리셋 축하 효과
- `confettiOnWeeklyLimitResetsEnabled`: 주간 리셋 축하 효과
- `appLanguage`: 앱 언어

### 2.6 UI Structure

#### 메뉴 바 아이콘 (StatusItemController)
- 시스템 트레이에 아이콘 표시
- 아이콘에 사용률 % 표시 (IconRenderer)
- 클릭시 드롭다운 메뉴 표시
- 프로바이더 전환 버튼
- 사용량 차트 (CostHistoryChart, CreditsHistoryChart)
- 설정 바로가기

#### 메뉴 카드 (MenuCardView)
- 프로바이더 로고 + 이름
- 사용량 프로그레스 바
- 세션/주간/월간 사용량 표시
- 크레딧 잔액
- 리셋 시간 카운트다운
- 비용 정보

#### 설정 뷰 (PreferencesView)
- GeneralPane: 기본 설정
- MenuBarPane: 메뉴 바 표시 설정
- MenuPane: 메뉴 설정
- ProvidersPane: 프로바이더별 설정
- NotificationsPane: 알림 설정
- AboutPane: 정보
- AdvancedPane: 고급 설정
- DebugPane: 디버그 설정

### 2.7 Notification System
- `AppNotifications`: 시스템 알림 권한 관리
- `SessionQuotaNotifications`: 세션 한도 알림
- `CodexResetCreditNotifier`: 크레딧 리셋 알림
- 알림 트리거: 사용량 변경, 한도 근접, 리셋 발생

---

## 3. Complete Provider List (60 Providers)

| # | Provider ID | Display Name | CLI Name | Has CLI | Has Web Cookie | Notes |
|---|-------------|--------------|----------|---------|----------------|-------|
| 1 | codex | Codex | codex | Yes | Yes | OpenAI Codex CLI |
| 2 | openai | OpenAI | openai | Yes | Yes | OpenAI API |
| 3 | azureopenai | Azure OpenAI | azureopenai | No | No | Azure OpenAI Service |
| 4 | claude | Claude | claude | Yes | Yes | Anthropic Claude |
| 5 | cursor | Cursor | cursor | Yes | Yes | Cursor IDE |
| 6 | opencode | OpenCode | opencode | Yes | Yes | OpenCode |
| 7 | opencodego | OpenCode Go | opencodego | Yes | No | OpenCode Go |
| 8 | alibaba | Alibaba | alibaba | Yes | Yes | Alibaba Coding Plan |
| 9 | alibabatokenplan | Alibaba Token Plan | alibabatokenplan | Yes | No | Alibaba Token Plan |
| 10 | factory | Factory | factory | No | Yes | Factory |
| 11 | gemini | Gemini | gemini | Yes | Yes | Google Gemini |
| 12 | antigravity | Antigravity | antigravity | Yes | Yes | Antigravity |
| 13 | copilot | Copilot | copilot | Yes | Yes | GitHub Copilot |
| 14 | devin | Devin | devin | No | Yes | Devin AI |
| 15 | zai | Zai | zai | Yes | Yes | Zai |
| 16 | minimax | MiniMax | minimax | No | Yes | MiniMax |
| 17 | manus | Manus | manus | No | Yes | Manus AI |
| 18 | kimi | Kimi | kimi | Yes | Yes | Moonshot Kimi |
| 19 | kilo | Kilo | kilo | No | No | Kilo |
| 20 | kiro | Kiro | kiro | No | Yes | AWS Kiro |
| 21 | vertexai | Vertex AI | vertexai | No | No | Google Vertex AI |
| 22 | augment | Augment | augment | No | Yes | Augment Code |
| 23 | jetbrains | JetBrains | jetbrains | No | No | JetBrains AI |
| 24 | kimik2 | Kimi K2 | kimik2 | Yes | No | Kimi K2 |
| 25 | moonshot | Moonshot | moonshot | No | No | Moonshot AI |
| 26 | amp | Amp | amp | No | Yes | Amp Code |
| 27 | t3chat | T3 Chat | t3chat | No | No | T3 Chat |
| 28 | ollama | Ollama | ollama | Yes | No | Local LLM |
| 29 | synthetic | Synthetic | synthetic | Yes | No | Synthetic |
| 30 | warp | Warp | warp | No | Yes | Warp Terminal |
| 31 | openrouter | Open Router | openrouter | No | Yes | OpenRouter |
| 32 | elevenlabs | ElevenLabs | elevenlabs | No | No | ElevenLabs |
| 33 | windsurf | Windsurf | windsurf | No | Yes | Windsurf IDE |
| 34 | zed | Zed | zed | No | No | Zed Editor |
| 35 | perplexity | Perplexity | perplexity | No | Yes | Perplexity AI |
| 36 | mimo | MiMo | mimo | Yes | Yes | Xiaomi MiMo |
| 37 | doubao | Doubao | doubao | No | Yes | ByteDance Doubao |
| 38 | sakana | Sakana | sakana | No | No | Sakana AI |
| 39 | abacus | Abacus | abacus | No | No | Abacus AI |
| 40 | mistral | Mistral | mistral | No | Yes | Mistral AI |
| 41 | deepseek | DeepSeek | deepseek | Yes | Yes | DeepSeek |
| 42 | codebuff | Codebuff | codebuff | No | No | Codebuff |
| 43 | crof | Crof | crof | No | No | Crof |
| 44 | venice | Venice | venice | No | No | Venice AI |
| 45 | commandcode | Command Code | commandcode | No | Yes | Command Code |
| 46 | qoder | Qoder | qoder | No | Yes | Qoder |
| 47 | stepfun | StepFun | stepfun | No | No | StepFun |
| 48 | bedrock | Bedrock | bedrock | No | No | AWS Bedrock |
| 49 | grok | Grok | grok | No | Yes | xAI Grok |
| 50 | groq | Groq | groq | No | No | Groq |
| 51 | llmproxy | LLM Proxy | llmproxy | No | No | LLM Proxy |
| 52 | litellm | LiteLLM | litellm | No | No | LiteLLM |
| 53 | deepgram | Deepgram | deepgram | No | No | Deepgram |
| 54 | poe | Poe | poe | No | Yes | Poe |
| 55 | chutes | Chutes | chutes | No | No | Chutes |
| 56 | crossmodel | Cross Model | crossmodel | No | No | CrossModel |
| 57 | clawrouter | Claw Router | clawrouter | No | No | ClawRouter |
| 58 | sub2api | Sub2API | sub2api | No | No | Sub2API |
| 59 | wayfinder | Wayfinder | wayfinder | No | No | Wayfinder |
| 60 | zenmux | ZenMux | zenmux | No | No | ZenMux |

---

## 4. Flutter Porting Architecture

### 4.1 Project Structure
```
codexbar_flutter/
├── lib/
│   ├── main.dart                    # 앱 엔트리포인트
│   ├── app.dart                     # MaterialApp 설정
│   ├── core/
│   │   ├── providers/               # 프로바이더 시스템
│   │   │   ├── provider_descriptor.dart
│   │   │   ├── provider_registry.dart
│   │   │   ├── provider_fetch_plan.dart
│   │   │   ├── provider_fetch_strategy.dart
│   │   │   ├── provider_metadata.dart
│   │   │   ├── provider_branding.dart
│   │   │   └── providers/           # 개별 프로바이더 구현
│   │   │       ├── claude/
│   │   │       ├── openai/
│   │   │       ├── cursor/
│   │   │       └── ...
│   │   ├── models/
│   │   │   ├── usage_snapshot.dart
│   │   │   ├── rate_window.dart
│   │   │   ├── provider_identity.dart
│   │   │   └── credits_snapshot.dart
│   │   ├── auth/
│   │   │   ├── auth_strategy.dart
│   │   │   ├── cli_token_resolver.dart
│   │   │   ├── browser_cookie_resolver.dart
│   │   │   └── token_race.dart
│   │   ├── fetch/
│   │   │   ├── usage_fetcher.dart
│   │   │   └── fetch_pipeline.dart
│   │   ├── storage/
│   │   │   ├── usage_store.dart
│   │   │   └── settings_store.dart
│   │   └── notifications/
│   │       └── notification_service.dart
│   ├── ui/
│   │   ├── tray/
│   │   │   ├── tray_manager.dart
│   │   │   └── icon_renderer.dart
│   │   ├── menu/
│   │   │   ├── menu_card_view.dart
│   │   │   ├── usage_progress_bar.dart
│   │   │   ├── cost_chart.dart
│   │   │   └── provider_switcher.dart
│   │   ├── settings/
│   │   │   ├── preferences_view.dart
│   │   │   ├── general_pane.dart
│   │   │   ├── menu_bar_pane.dart
│   │   │   ├── providers_pane.dart
│   │   │   ├── notifications_pane.dart
│   │   │   └── about_pane.dart
│   │   └── shared/
│   │       ├── widgets/
│   │       └── theme/
│   └── l10n/                        # 다국어 지원
├── assets/
│   └── icons/                       # 프로바이더 아이콘
├── test/
├── pubspec.yaml
└── flutter_port/
    ├── PORTING_GUIDE.md             # 이 문서
    └── CHANGELOG_TRACKER.md         # 업데이트 추적
```

### 4.2 Key Flutter Packages (예상)
- `system_tray`: 시스템 트레이 아이콘
- `window_manager`: 윈도우 관리 (표시/숨김/크기)
- `tray_manager`: 고급 트레이 관리
- `http` / `dio`: HTTP 요청
- `shared_preferences`: 설정 저장
- `flutter_local_notifications`: 시스템 알림
- `fl_chart`: 차트 렌더링
- `provider` / `riverpod`: 상태 관리
- `json_annotation`: JSON 직렬화
- `path_provider`: 파일 경로
- `process_run`: CLI 프로세스 실행

### 4.3 Auth Strategy Implementation
```dart
abstract class AuthStrategy {
  String get id;
  ProviderFetchKind get kind;
  Future<bool> isAvailable(ProviderFetchContext context);
  Future<ProviderFetchResult> fetch(ProviderFetchContext context);
  bool shouldFallback(Object error, ProviderFetchContext context);
}

class FetchPipeline {
  Future<ProviderFetchOutcome> fetch({
    required ProviderFetchContext context,
    required UsageProvider provider,
  }) async {
    final strategies = await resolveStrategies(context);
    for (final strategy in strategies) {
      if (!await strategy.isAvailable(context)) continue;
      try {
        final result = await strategy.fetch(context);
        return ProviderFetchOutcome.success(result);
      } catch (e) {
        if (!strategy.shouldFallback(e, context)) rethrow;
      }
    }
    return ProviderFetchOutcome.failure(ProviderFetchError.noAvailableStrategy);
  }
}
```

### 4.4 Race Strategy (CLI vs Cookie)
```dart
class TokenRaceStrategy {
  Future<ProviderFetchResult> raceFetch({
    required AuthStrategy cliStrategy,
    required AuthStrategy cookieStrategy,
    required ProviderFetchContext context,
  }) async {
    // 둘 다 사용 가능한지 확인
    final cliAvailable = await cliStrategy.isAvailable(context);
    final cookieAvailable = await cookieStrategy.isAvailable(context);
    
    if (cliAvailable && cookieAvailable) {
      // 경쟁: 먼저 응답하는 쪽 사용
      return await Future.any([
        cliStrategy.fetch(context),
        cookieStrategy.fetch(context),
      ]);
    } else if (cliAvailable) {
      return await cliStrategy.fetch(context);
    } else if (cookieAvailable) {
      return await cookieStrategy.fetch(context);
    }
    throw ProviderFetchError.noAvailableStrategy;
  }
}
```

---

## 5. UI Mapping (Swift → Flutter)

| Swift Component | Flutter Equivalent | Notes |
|----------------|-------------------|-------|
| NSStatusBar (메뉴 바) | system_tray + TrayManager | 시스템 트레이 아이콘 |
| NSMenu (드롭다운) | Custom Popup Window | Flutter 윈도우로 구현 |
| MenuCardView | MenuCardWidget | 사용량 카드 |
| PreferencesView | PreferencesScreen | 설정 화면 |
| IconRenderer | CustomPainter | 아이콘 렌더링 |
| SwiftUI Charts | fl_chart | 차트 라이브러리 |
| @Observable + @State | Riverpod/Provider | 상태 관리 |
| UserDefaults | shared_preferences | 설정 저장 |
| Keychain | flutter_secure_storage | 보안 저장소 |
| NSUserNotifications | flutter_local_notifications | 시스템 알림 |

---

## 6. Change Tracking Protocol

### 6.1 Checkpoint Format
CodexBar 원본의 변경을 추적하기 위해 다음 정보를 기록합니다:

```markdown
## Checkpoint: [날짜]
- **Commit**: [해시]
- **Version**: [버전]
- **변경 사항**: [요약]
- **영향받은 프로바이더**: [목록]
- **영향받은 파일**: [목록]
- **포팅 필요 작업**: [상세]
```

### 6.2 Update Detection
원본 프로젝트의 업데이트를 감지하는 방법:
1. `git log --oneline [last_checkpoint_commit]..HEAD` 실행
2. 변경된 파일 분석
3. 프로바이더별 변경 사항 분류
4. 포팅에 필요한 작업 목록 생성

### 6.3 Change Categories
- **Provider Addition**: 새 프로바이더 추가
- **Provider Update**: 기존 프로바이더 API 변경
- **Core Model Change**: 데이터 모델 변경
- **UI Change**: 화면 구성 변경
- **Auth Change**: 인증 방식 변경
- **Config Change**: 설정 구조 변경

---

## 7. Implementation Phases

### Phase 1: Foundation
- [ ] Flutter 프로젝트 초기 설정
- [ ] 코어 데이터 모델 구현 (UsageSnapshot, RateWindow 등)
- [ ] 프로바이더 인터페이스 정의
- [ ] 설정 저장소 구현

### Phase 2: Auth & Fetch
- [ ] CLI 토큰 해석기 구현
- [ ] 브라우저 쿠키 해석기 구현
- [ ] 페칭 파이프라인 구현
- [ ] 경쟁(Race) 전략 구현

### Phase 3: Providers (Batch 1 - Core)
- [ ] Codex, OpenAI, Claude, Cursor, Gemini
- [ ] Copilot, DeepSeek, Mistral, Perplexity

### Phase 4: Providers (Batch 2)
- [ ] 나머지 프로바이더 구현

### Phase 5: UI
- [ ] 시스템 트레이 구현
- [ ] 메뉴 카드 UI
- [ ] 설정 화면
- [ ] 차트 컴포넌트

### Phase 6: Notifications & Polish
- [ ] 사용량 변경 알림
- [ ] 로컬라이제이션
- [ ] 테스트
- [ ] 빌드/배포 설정
