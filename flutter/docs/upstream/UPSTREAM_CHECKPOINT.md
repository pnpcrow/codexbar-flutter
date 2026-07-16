# 업스트림 체크포인트

이 문서는 Flutter 포팅의 **기준 시점**을 기록하고, 상위 Swift 프로젝트(CodexBar)에 업데이트가 생겼을 때 변경분만 선별 반영하기 위한 절차를 정의합니다.

## 현재 포팅 기준 시점

| 항목 | 값 |
|------|-----|
| 저장소 | https://github.com/steipete/codexbar (또는 현재 fork의 upstream remote) |
| 커밋 해시 | `59c081332066710d555d5b56c2948b0784cfa316` |
| 단축 해시 | `59c08133` |
| 커밋 날짜 | 2026-07-16T02:58:08-07:00 |
| 커밋 주제 | `feat: add ZenMux Management API usage (#2133)` |
| 앱 버전 | 0.43.1 |
| 빌드 번호 | 105 |
| 기록된 날짜 | 2026-07-16 |

> 이 시점의 Swift 소스(`Sources/`)를 기준으로 Dart 포팅이 이루어졌습니다.

## 업스트림 업데이트 확인 절차

상위 프로젝트에 새 커밋이 생겼는지 정기적으로 확인하려면:

```bash
# 1. upstream remote가 등록되어 있는지 확인
git remote -v

# 2. upstream이 없으면 추가
git remote add upstream https://github.com/steipete/codexbar.git

# 3. 최신 커밋 가져오기 (현재 작업 브랜치에 영향 없음)
git fetch upstream

# 4. 체크포인트 이후 새로운 커밋 목록 확인
git log 59c08133..upstream/main --oneline

# 5. 변경된 파일 목록 확인 (Swift 소스만)
git diff --stat 59c08133..upstream/main -- Sources/

# 6. 특정 파일의 변경 내용 상세 확인
git diff 59c08133..upstream/main -- Sources/CodexBarCore/Providers/OpenAI/
```

## 업데이트 반영 워크플로우

새 업스트림 커밋을 발견하면 다음 단계로 반영합니다:

1. **변경 파일 식별**: 위 절차 5번으로 변경된 Swift 파일 목록을 얻는다.
2. **PORT_MAP.md 조회**: 각 Swift 파일을 `PORT_MAP.md`에서 찾아 해당 Dart 포팅 파일과 현재 상태를 확인한다.
3. **상태 분류**:
   - `✅ 포팅됨` → Dart 쪽에 동일한 변경을 반영한다.
   - `🟡 부분 포팅` → 변경된 부분이 포팅 범위 내인지 확인 후 반영한다.
   - `⬜ 대기` → 아직 포팅되지 않은 영역. 우선순위에 따라 반영 여부 결정.
   - `➖ 간략화/제외` → 의도적으로 제외한 영역. `DECISIONS.md` 사유 재검토.
4. **체크포인트 업데이트**: 반영 완료 후 이 문서의 "현재 포팅 기준 시점"을 새 커밋으로 갱신한다.
5. **변경 이력 기록**: 아래 "변경 이력"에 반영 내역을 추가한다.

## 변경 이력

| 날짜 | 반영 커밋 | 반영 내용 | 비고 |
|------|-----------|-----------|------|
| 2026-07-16 | `59c08133` | 초기 포팅 기준점 설정 | v0.43.1 (build 105) |
