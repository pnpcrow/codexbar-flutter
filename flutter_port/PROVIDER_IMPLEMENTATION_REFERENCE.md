# Provider Implementation Reference

## Overview
이 문서는 각 프로바이더의 구현 세부사항을 캡처합니다.
Flutter 포팅 시 각 프로바이더를 동일하게 구현하기 위한 참조 자료입니다.

---

## Provider Token Sources

각 프로바이더의 인증 토큰 소스 (환경변수, CLI, 브라우저 쿠키 등):

### Codex
- **CLI Name**: `codex`
- **CLI Binary**: `codex` (PATH에서 검색)
- **Auth**: CLI 자체 인증 (ChatGPT 계정 또는 API 키)
- **Fetch**: RPC (JSON-RPC over stdin/stdout) → `account/rateLimits/read`
- **Dashboard**: https://chatgpt.com/codex/settings
- **Status Page**: https://status.openai.com/

### OpenAI
- **CLI Name**: `openai`
- **Auth**: `OPENAI_API_KEY` 환경변수
- **Fetch**: OpenAI API 직접 호출
- **Dashboard**: https://platform.openai.com/usage

### Claude
- **CLI Name**: `claude`
- **Auth Sources** (우선순위):
  1. OAuth (Keychain에 저장된 Claude OAuth 자격증명)
  2. CLI (`claude` CLI 실행, `~/.claude/` 디렉토리)
  3. Web (브라우저 쿠키 - Chrome/Safari/Firefox)
  4. Admin API (`ANTHROPIC_API_KEY` 환경변수)
- **Fetch Strategies**: `ClaudeOAuthFetchStrategy`, `ClaudeCLIFetchStrategy`, `ClaudeWebFetchStrategy`, `ClaudeAdminAPIFetchStrategy`
- **Dashboard**: https://console.anthropic.com/settings/billing
- **Status Page**: https://status.claude.com/

### Cursor
- **CLI Name**: `cursor`
- **Auth**: 브라우저 쿠키 (Safari 우선, Chrome 등)
- **Fetch**: Cursor API
- **Dashboard**: https://cursor.com/dashboard

### Gemini
- **CLI Name**: `gemini`
- **Auth**: 브라우저 쿠키, Google OAuth
- **Fetch**: Gemini API
- **Status Workspace Product ID**: AIzaSy...

### Copilot
- **CLI Name**: `copilot`
- **Auth**: `COPILOT_API_TOKEN` 환경변수, 브라우저 쿠키 (Chrome)
- **Fetch**: Copilot API

### DeepSeek
- **Auth**: `DEEPSEEK_API_KEY` 환경변수
- **Fetch**: DeepSeek API

### Mistral
- **Auth**: 브라우저 쿠키
- **Fetch**: Mistral API

### Perplexity
- **Auth**: `PERPLEXITY_SESSION_TOKEN` 환경변수, 브라우저 쿠키
- **Fetch**: Perplexity API

### MiMo
- **Auth**: CLI (`mimo`), 브라우저 쿠키 (Safari, Chrome, Chrome Beta, Chrome Canary, Firefox, Edge)
- **Fetch**: MiMo API

### Zai
- **Auth**: `ZAI_API_TOKEN` 환경변수
- **Fetch**: Zai API

### MiniMax
- **Auth**: `MINIMAX_API_TOKEN` 환경변수, `MINIMAX_COOKIE` 환경변수
- **Fetch**: MiniMax API

### Kimi
- **Auth**: `KIMI_AUTH_TOKEN` 환경변수, `KIMI_API_KEY` 환경변수, 브라우저 쿠키
- **Fetch**: Kimi API

### Kimi K2
- **Auth**: `KIMI_K2_API_KEY` 환경변수
- **Fetch**: Kimi K2 API

### Moonshot
- **Auth**: `MOONSHOT_API_KEY` 환경변수
- **Fetch**: Moonshot API

### Amp
- **Auth**: `AMP_API_TOKEN` 환경변수
- **Fetch**: Amp API

### OpenRouter
- **Auth**: `OPENROUTER_API_TOKEN` 환경변수
- **Fetch**: OpenRouter API

### ElevenLabs
- **Auth**: `ELEVENLABS_API_KEY` 환경변수
- **Fetch**: ElevenLabs API

### Groq
- **Auth**: `GROQ_API_KEY` 환경변수
- **Fetch**: Groq API

### LLM Proxy
- **Auth**: `LLMPROXY_API_KEY` 환경변수
- **Fetch**: LLM Proxy API

### LiteLLM
- **Auth**: `LITELLM_API_KEY` 환경변수
- **Fetch**: LiteLLM API

### ClawRouter
- **Auth**: `CLAWROUTER_API_KEY` 환경변수
- **Fetch**: ClawRouter API

### CrossModel
- **Auth**: `CROSSMODEL_API_TOKEN` 환경변수
- **Fetch**: CrossModel API

### Deepgram
- **Auth**: `DEEPGRAM_API_KEY` 환경변수, `DEEPGRAM_PROJECT_ID` 환경변수
- **Fetch**: Deepgram API

### Codebuff
- **Auth**: `CODEBUFF_API_KEY` 환경변수, 인증 파일 (`~/.codebuff/auth.json`)
- **Fetch**: Codebuff API

### Kilo
- **Auth**: `KILO_API_KEY` 환경변수, 인증 파일
- **Fetch**: Kilo API

### Warp
- **Auth**: `WARP_API_KEY` 환경변수
- **Fetch**: Warp API

### Doubao
- **Auth**: `DOUBAO_API_KEY` 환경변수
- **Fetch**: Doubao API

### Sakana
- **Auth**: 없음 (로컬 프로브)
- **Fetch**: Sakana API

### Abacus
- **Auth**: 없음
- **Fetch**: Abacus API

### StepFun
- **Auth**: `STEPFUN_TOKEN` 환경변수
- **Fetch**: StepFun API

### Poe
- **Auth**: `POE_API_KEY` 환경변수, 브라우저 쿠키
- **Fetch**: Poe API

### Venice
- **Auth**: `VENICE_API_KEY` 환경변수
- **Fetch**: Venice API

### Crof
- **Auth**: `CROF_API_KEY` 환경변수
- **Fetch**: Crof API

### Grok
- **Auth**: 브라우저 쿠키 (Chrome)
- **Fetch**: Grok API

### Qoder
- **Auth**: 브라우저 쿠키 (Chrome)
- **Fetch**: Qoder API

### Devin
- **Auth**: 브라우저 쿠키 (Chrome)
- **Fetch**: Devin API

### Manus
- **Auth**: 브라우저 쿠키
- **Fetch**: Manus API

### Bedrock
- **Auth**: `AWS_ACCESS_KEY_ID` 환경변수
- **Fetch**: AWS Bedrock API

### Factory
- **Auth**: 브라우저 쿠키
- **Fetch**: Factory API

### Augment
- **Auth**: 브라우저 쿠키
- **Fetch**: Augment API

### Windsurf
- **Auth**: 브라우저 쿠키
- **Fetch**: Windsurf API

### Command Code
- **Auth**: 브라우저 쿠키
- **Fetch**: Command Code API

### Kiro
- **Auth**: 브라우저 쿠키
- **Fetch**: Kiro API

---

## Provider Fetch Pattern Categories

### Category 1: CLI-based (프로세스 실행)
프로바이더: Codex, Claude, OpenCode, OpenCodeGo, Alibaba, AlibabaTokenPlan, Antigravity, Synthetic, MiMo, KimiK2, Ollama

패턴:
1. CLI 바이너리 경로 탐색 (`which` 또는 PATH 검색)
2. CLI 실행하여 JSON 출력 캡처
3. JSON 파싱하여 UsageSnapshot 생성

### Category 2: API Key-based (환경변수)
프로바이더: OpenAI, AzureOpenAI, DeepSeek, Moonshot, Amp, OpenRouter, ElevenLabs, Groq, LLMProxy, LiteLLM, ClawRouter, CrossModel, Deepgram, Codebuff, Kilo, Warp, Doubao, StepFun, Venice, Crof, Bedrock

패턴:
1. 환경변수에서 API 키 읽기
2. HTTP API 호출 (Authorization: Bearer <key>)
3. 응답 파싱하여 UsageSnapshot 생성

### Category 3: Web Cookie-based (브라우저 쿠키)
프로바이더: Claude(Web), Cursor, Factory, Devin, Manus, Grok, Qoder, Perplexity, Mistral, Augment, Windsurf, Command Code, Kiro

패턴:
1. SweetCookieKit으로 브라우저 쿠키 추출
2. 쿠키 헤더로 웹 API 호출
3. 응답 파싱하여 UsageSnapshot 생성

### Category 4: Hybrid (CLI + Web Cookie)
프로바이더: Claude, Copilot, Kimi, MiMo, Zai, MiniMax

패턴:
1. CLI와 Web Cookie 모두 시도 가능 여부 확인
2. 우선순위에 따라 전략 결정
3. 첫 번째 성공 전략의 결과 사용

### Category 5: Local Probe (로컬 프로브)
프로바이더: Sakana, Ollama

패턴:
1. 로컬 API 엔드포인트 호출
2. 응답 파싱

---

## Environment Variables Summary

```
# OpenAI
OPENAI_API_KEY

# Azure OpenAI
AZURE_OPENAI_API_KEY

# Claude
ANTHROPIC_API_KEY

# Copilot
COPILOT_API_TOKEN

# DeepSeek
DEEPSEEK_API_KEY

# MiniMax
MINIMAX_API_TOKEN
MINIMAX_COOKIE

# Kimi
KIMI_AUTH_TOKEN
KIMI_API_KEY

# Kimi K2
KIMI_K2_API_KEY

# Moonshot
MOONSHOT_API_KEY

# Amp
AMP_API_TOKEN

# Zai
ZAI_API_TOKEN

# Synthetic
SYNTHETIC_API_KEY

# OpenRouter
OPENROUTER_API_TOKEN

# ElevenLabs
ELEVENLABS_API_KEY

# Groq
GROQ_API_KEY

# LLM Proxy
LLMPROXY_API_KEY

# LiteLLM
LITELLM_API_KEY

# ClawRouter
CLAWROUTER_API_KEY

# CrossModel
CROSSMODEL_API_TOKEN

# Deepgram
DEEPGRAM_API_KEY
DEEPGRAM_PROJECT_ID

# Codebuff
CODEBUFF_API_KEY

# Kilo
KILO_API_KEY

# Warp
WARP_API_KEY

# Doubao
DOUBAO_API_KEY

# StepFun
STEPFUN_TOKEN

# Poe
POE_API_KEY

# Venice
VENICE_API_KEY

# Crof
CROF_API_KEY

# Bedrock
AWS_ACCESS_KEY_ID

# Perplexity
PERPLEXITY_SESSION_TOKEN
```

---

## Browser Cookie Import Order

각 프로바이더의 브라우저 쿠키 가져오기 우선순위:

| Provider | Default Browser Order |
|----------|----------------------|
| Claude | Safari, Chrome, Firefox, (기타) |
| Codex | Safari, Chrome, Firefox, (기타) |
| Cursor | Safari, (Chrome, Firefox, 기타) |
| MiMo | Safari, Chrome, Chrome Beta, Chrome Canary, Firefox, Edge |
| Grok | Chrome |
| Devin | Chrome |
| Copilot | Chrome |
| Qoder | Chrome |
| OpenCode | Chrome, Dia |
| Others | Default order |

---

## Fetch Strategy Resolution (Auto Mode)

Auto 모드에서의 전략 해석 순서:

### Claude (가장 복잡한 경우)
```
1. Admin API 키가 있으면 → AdminAPIFetchStrategy
2. 선택된 Admin API 계정이 있으면 → AdminAPIFetchStrategy
3. Source Planner로 결정:
   a. App Auto: OAuth → CLI → Web
   b. CLI Auto: Web → CLI
4. 각 단계에서 isPlausiblyAvailable 확인
5. 사용 가능한 첫 번째 전략 실행
6. 실패시 shouldFallback() 확인 후 다음 전략으로
```

### 일반 프로바이더 (API Key + Web Cookie)
```
1. API 키 환경변수 확인
2. 브라우저 쿠키 가용성 확인
3. 우선순위에 따라 전략 결정
4. 첫 번째 성공 전략 사용
```

---

## RateWindow Display Logic

사용량 표시 로직:
- `usedPercent`: 0-100 사이 값
- `windowMinutes`: 윈도우 길이 (예: 300 = 5시간)
- `resetsAt`: 리셋 시간
- `remainingPercent`: 100 - usedPercent
- 프로바이더별 특수 처리 (Cursor: secondary window, Perplexity: automatic window selection)
