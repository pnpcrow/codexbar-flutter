# 포팅 결정 기록

Swift CodexBar를 Dart/Flutter로 포팅하면서 내린 아키텍처 결정, 간략화, 대체, 보류 항목과 그 사유를 기록합니다.

## 원칙

- **기능·작동 방식·화면 구성은 그대로 유지**하는 것을 목표로 한다.
- 단, 단일 세션에서 60개 프로바이더 + 복잡한 인증을 전부 1:1 포팅하는 것은 비현실적이므로, **확장 가능한 아키텍처**를 먼저 세우고 핵심부터 점진적으로 채운다.
- 상위 프로젝트 업데이트를 추적 가능하도록, 생략/간략화한 영역은 명시적으로 기록한다.

## 사용자 확정 결정 (2026-07-16)

1. **핵심 프로바이더 우선**: 전체 60개 중 API키 기반 4개(openai, anthropic, openrouter, deepseek)를 먼저 포팅하고, 파이프라인은 60개까지 확장 가능하게 설계.
2. **인증 범위**: 설정에서 API키/토큰을 입력받는 방식 먼저. OAuth·브라우저 쿠키 가져오기·CLI 파싱은 후속.
3. **알림**: "이전 사용량 ≠ 현재 사용량" 변화 감지 알림(ON/OFF) + 사용자 설정 임계치(% 도달) 경고. 기존 CodexBar의 세분화된 세션 쿼터 상태기계는 후속.
4. **저장소 배치**: `flutter/` 서브디렉토리. 기존 Swift 소스는 루트에 보존하여 업스트림 병합 간섭을 없앰.
5. **시스템 트레이**: 현재 Linux(Cinnamon 6.6.7 + XApp Status Applet)에서 작동 확인됨 → `tray_manager` + `window_manager` 사용. Flutter는 순수 창 없는 메뉴바 앱을 만들 수 없으므로 "숨김 창 + 트레이 아이콘 + close-to-tray" 패턴 적용.

## 아키텍처 결정

### 상태 관리: Riverpod
- Swift는 `@Observable` + `@MainActor` (`UsageStore`, `SettingsStore`).
- Dart는 `flutter_riverpod`의 `Notifier`/`AsyncNotifier`로 미러. SwiftUI의 선언적 갱신과 가장 대응이 깔끔하고, 테스트 용이성이 좋음. `Provider`/`Bloc` 대신 Riverpod 선택.

### 인증 저장: flutter_secure_storage
- Swift는 Keychain. Dart는 `flutter_secure_storage`가 Linux(libsecret/keyring), macOS(Keychain), Windows(DPAPI)를 추상화.
- API키는 secure_storage에, 그 외 스칼라 설정은 `shared_preferences`, 프로바이더 목록/활성화는 JSON config 파일(`path_provider` 경로)에 저장. 이는 Swift의 dual storage(UserDefaults + CodexBarConfig JSON) 구조와 대응.

### 아이콘 렌더링: CustomPainter
- Swift는 CoreGraphics로 36×36px 템플릿 NSImage 생성 후 `isTemplate = true`.
- Dart는 `CustomPainter`로 동일 픽셀 그리드 재현. 트레이 아이콘은 `tray_manager`가 PNG/바이트를 요구하므로, `ui.PictureRecorder` → `ui.Image` → PNG bytes로 변환하여 전달. 모노크롬 템플릿은 색상을 시스템 테마에 맞춰 적용.

## 간략화 / 의도적 생략

| 항목 | 사유 | 후속 계획 |
|------|------|-----------|
| UsageSnapshot provider별 상세 필드 20+개 (kiroUsage, ampUsage, zaiUsage 등) | 초기 4개 API키 프로바이더는 사용하지 않음 | 각 프로바이더 구현 시 추가 |
| 크리처 애니메이션 전체 (60개 페르소나, blink/wiggle/tilt, morph) | 구현량 과대. 시그니처 기능이므로 Codex/Claude 핵심은 포팅 | 사용자 반응 보고 확장 |
| 복잡한 가시성 복구 로직 (NSStatusItem 재생성, Control Center 대응) | tray_manager가 Linux에서 직접 SNI 처리 | 플랫폼별 이슈 발생 시 보완 |
| 메뉴 "스마트 업데이트" diff (canSmartUpdate 등) | Flutter는 재빌드 비용이 낮아 불필요 | — |
| thermal/power 신호 기반 adaptive 지연 (Linux) | Linux에서 신호 획득 경로가 다름 | 후속 보완, 기본 nominal 처리 |
| 23개 로케일 | en + ko 먼저 | .arb 확장 |
| 차트 서브메뉴 (비용/크레딧/계획 이력) | 우선순위 낮음 | fl_chart 등으로 후속 |
| 세션 쿼터 고갈/복원 상태기계 (SessionQuotaNotifications) | 사용자가 "단순 변화 알림 + 임계치"를 선택 | 임계치 경고로 1차 커버, 상세는 후속 |

## 보류 항목 (후속 세션)

- OAuth 인증: Codex(`CodexOAuthFetchStrategy`), Claude, Gemini/Antigravity, VertexAI. `swift-crypto` 기반 JWT/PKCE → Dart `oauth2` 또는 수동 구현.
- 브라우저 쿠키 가져오기: Cursor/Claude web/Copilot 등. Swift는 `SweetCookieKit`. Dart는 각 브라우저 쿠키 DB 직접 읽기 필요.
- CLI 파싱: `codex app-server` JSON-RPC, JetBrains, Kilo, Augment 로컬 프로브.
- Sparkle 자동 업데이트 → Linux는 AppImage/Flatpak 배포 + 자체 업데이터.
- 전역 핫키(KeyboardShortcuts), 시작 시 실행(LaunchAtLogin), macOS 위젯 확장.
- 나머지 56개 프로바이더.
