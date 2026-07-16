# 포팅 매핑 테이블 (Swift ↔ Dart)

상위 Swift 프로젝트 파일과 Dart 포팅 파일의 대응 관계 및 포팅 상태를 추적합니다.

## 상태 범례

- ✅ 포팅됨 — 동등한 기능이 Dart에 구현됨
- 🟡 부분 — 핵심은 포팅, 일부 생략/간략화
- ⬜ 대기 — 아직 포팅되지 않음
- ➖ 제외 — 의도적으로 포팅하지 않음 (사유는 DECISIONS.md)

## 코어 데이터 모델 & 엔진 (CodexBarCore)

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBarCore/UsageFetcher.swift` (RateWindow, NamedRateWindow, ProviderIdentitySnapshot, UsageSnapshot 핵심) | `lib/core/models/rate_window.dart`, `lib/core/models/usage_snapshot.dart`, `lib/core/models/provider_identity.dart` | 🟡 | UsageSnapshot의 provider별 상세 필드(kiroUsage 등 20+)는 공통 핵심만 포팅, 개별 프로바이더 구현 시 추가 |
| `Sources/CodexBarCore/Providers/Providers.swift` (UsageProvider enum 60개, ProviderMetadata) | `lib/core/providers/usage_provider.dart` | 🟡 | 60개 enum case 전부 정의, 활성 구현체는 4개 |
| `Sources/CodexBarCore/Providers/ProviderDescriptor.swift` (ProviderDescriptor, ProviderMetadata, ProviderBranding) | `lib/core/providers/provider_descriptor.dart` | 🟡 | 메타데이터/브랜딩 핵심만 |
| `Sources/CodexBarCore/Providers/ProviderFetchPlan.swift` (ProviderFetchStrategy, ProviderFetchPipeline) | `lib/core/providers/provider_fetch_strategy.dart`, `lib/core/providers/provider_fetch_pipeline.dart` | ✅ | 파이프라인 + 전략 패턴 그대로 |
| `Sources/CodexBarCore/Providers/Credits/CreditsModels.swift` (CreditsSnapshot) | `lib/core/models/credits_snapshot.dart` | ✅ | 핵심 모델 |
| `Sources/CodexBarCore/Providers/ProviderCost/...` (ProviderCostSnapshot) | `lib/core/models/provider_cost.dart` | ✅ | 핵심 모델 |

## 적응형 새로고침 (AdaptiveRefreshCore)

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/AdaptiveRefreshCore/AdaptiveRefreshPolicyCore.swift` | `lib/core/refresh/adaptive_refresh_policy.dart` | ✅ | 순수 결정 테이블, 그대로 포팅 |

## 아이콘 렌더러 (CodexBar 앱)

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBar/IconRenderer.swift` | `lib/ui/tray/icon_renderer.dart` (CustomPainter) | 🟡 | 두 미터바 + stale 디밍 + 상태 점 + 캐싱 포팅. 크리처 애니메이션(blink/wiggle/tilt, 60개 페르소나)은 Codex/Claude 핵심만 |
| `Sources/CodexBar/LoadingPattern.swift` | `lib/ui/tray/loading_pattern.dart` | 🟡 | knightRider/cylon 기본만 |
| `Sources/CodexBar/DisplayLink.swift` | (Flutter AnimationController/Ticker로 대체) | ➖ | Flutter에 CADisplayLink 불필요 |
| `Sources/CodexBar/ProviderBrandIcon.swift` | `lib/ui/tray/provider_brand_icon.dart` | ⬜ | 브랜드 SVG 로고 — 후속 |

## 메뉴 UI (CodexBar 앱)

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBar/StatusItemController.swift` (+ extensions) | `lib/ui/tray/tray_controller.dart`, `lib/state/usage_store.dart` | 🟡 | NSStatusItem → tray_manager. 복잡한 가시성 복구 로직은 단순화 |
| `Sources/CodexBar/MenuCardView.swift` (+ extensions) | `lib/ui/menu_card/menu_card_view.dart` | 🟡 | 사용량 카드 + 진행률 바 + 프로바이더 스위처 |
| `Sources/CodexBar/UsageProgressBar.swift` | `lib/ui/menu_card/usage_progress_bar.dart` | ✅ | |
| `Sources/CodexBar/MenuDescriptor.swift`, `MenuContent.swift` | `lib/ui/menu_card/menu_action.dart` | 🟡 | 액션(새로고침/설정/종료)만 |
| 차트 뷰 (CostHistoryChart, CreditsHistoryChart 등) | — | ⬜ | 후속 |

## 설정 (CodexBar 앱)

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBar/SettingsStore.swift` (+ extensions) | `lib/state/settings_store.dart`, `lib/core/storage/settings_store_io.dart` | 🟡 | 핵심 설정만. UserDefaults → shared_preferences + JSON config |
| `Sources/CodexBar/PreferencesView.swift`, `Preferences*Pane.swift` | `lib/ui/settings/settings_view.dart`, 각 pane 파일 | 🟡 | General/Notifications/MenuBar/Providers만 |
| `Sources/CodexBar/CodexBarConfig` (JSON config) | `lib/core/storage/codexbar_config.dart` | 🟡 | 프로바이더 목록/활성화/API키 |

## 알림

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBar/AppNotifications.swift` | `lib/core/notifications/app_notifications.dart` | 🟡 | flutter_local_notifications 래퍼 |
| (신규) 변화 감지 알림 | `lib/core/notifications/usage_change_detector.dart` | ✅ | Swift에 없는 신규 기능 (사용자 요구) |
| `Sources/CodexBar/SessionQuotaNotifications.swift` | — | ⬜ | 세션 쿼터 상태기계 — 후속 |
| `Sources/CodexBar/QuotaWarningAlertOverlayController.swift` | — | ⬜ | 화면 알림 오버레이 — 후속 |

## 상태 관리

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBar/UsageStore.swift` (+ extensions) | `lib/state/usage_store.dart` | 🟡 | 스냅샷/새로고침/타이머 핵심만 |
| `Sources/CodexBar/UsageFetcher.swift` (런타임 조정부) | `lib/state/usage_fetcher.dart` | 🟡 | |
| `Sources/CodexBar/ProviderRefreshCoordinator.swift` | (usage_store 내 통합) | ➖ | 단순화 |

## 인증 (초기 범위: API키만)

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBarCore/Providers/OpenAI/...` | `lib/core/providers/implementations/openai_fetch_strategy.dart` | 🟡 | API key 경로만 |
| `Sources/CodexBarCore/Providers/Claude/...` (Anthropic) | `lib/core/providers/implementations/anthropic_fetch_strategy.dart` | 🟡 | API key 경로만 (OAuth는 후속) |
| `Sources/CodexBarCore/Providers/OpenRouter/...` | `lib/core/providers/implementations/openrouter_fetch_strategy.dart` | 🟡 | |
| `Sources/CodexBarCore/Providers/DeepSeek/...` | `lib/core/providers/implementations/deepseek_fetch_strategy.dart` | 🟡 | |
| 키체인/토큰 스토어들 | `lib/core/storage/secure_storage.dart` | 🟡 | flutter_secure_storage 래퍼 |
| OAuth (Codex/Claude/Gemini) | — | ⬜ | 후속 |
| 브라우저 쿠키 가져오기 (Cursor 등) | — | ⬜ | 후속 (SweetCookieKit 상당) |
| CLI 파싱 (codex app-server) | — | ⬜ | 후속 |

## 나머지 56개 프로바이더

각각 `lib/core/providers/implementations/<provider>_fetch_strategy.dart`에 개별 추가. 파이프라인 아키텍처는 확장 준비됨.

| 상태 | 프로바이더 수 |
|------|---------------|
| 🟡 초기 구현 | 4 (openai, anthropic, openrouter, deepseek) |
| ⬜ 대기 | 56 (codex, claude-oauth, cursor, gemini, copilot, zai, minimax, kimi, kiro, ...) |

## i18n

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| 23개 로케일 Localizable.strings | `lib/l10n/*.arb` | 🟡 | en + ko만 초기; 나머지 후속 |

## 앱 진입 & 인프라

| Swift 원본 | Dart 포팅 | 상태 | 비고 |
|------------|-----------|------|------|
| `Sources/CodexBar/CodexbarApp.swift` (App, AppDelegate) | `lib/main.dart`, `lib/app.dart` | 🟡 | Settings 창 + 트레이 부트스트랩 |
| Sparkle (자동 업데이트) | — | ⬜ | 후속 (Linux는 AppImage/Flatpak) |
| KeyboardShortcuts (전역 핫키) | — | ⬜ | 후속 (hotkey_manager 등) |
| LaunchAtLogin (ServiceManagement) | — | ⬜ | 후속 |
| WidgetExtension | — | ⬜ | 후속 |
