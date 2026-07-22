# CodexBar Provider Specification (Complete Reference)

> Based on CodexBar v0.43.1 (build 105) at commit 59c08133
> Generated: 2026-07-18

## Legend

- **Auth Type**: `cli` = CLI binary, `web` = Browser cookies, `api` = API key, `oauth` = OAuth token
- **Source Modes**: What the provider supports (`auto`, `cli`, `web`, `api`, `oauth`)
- **Env Var**: Environment variable for API key
- **Web Domain**: Domain for browser cookie extraction
- **API Endpoint**: REST/gRPC endpoint for data fetching

---

## 1. Codex
- **Auth**: `oauth` (primary), `cli` (fallback)
- **Source Modes**: `auto, web, cli, oauth`
- **CLI Binary**: `codex`
- **OAuth Token**: `~/.codex/auth.json` → `tokens.access_token`
- **API Endpoint**: `GET https://chatgpt.com/backend-api/wham/usage`
- **Auth Header**: `Authorization: Bearer <access_token>`
- **Extra Header**: `ChatGPT-Account-Id: <account_id>`
- **Response**: `{ plan_type, rate_limit: { primary_window, secondary_window }, credits: { balance } }`
- **Dashboard**: `https://chatgpt.com/codex/settings/usage`

## 2. Claude
- **Auth**: `oauth` (primary), `cli`, `web`, `api`
- **Source Modes**: `auto, api, web, cli, oauth`
- **CLI Binary**: `claude`
- **OAuth**: Keychain-stored credentials
- **Web Cookies**: `sessionKey` from `.claude.ai`
- **API Key**: `ANTHROPIC_API_KEY` → `https://api.anthropic.com/v1/organizations/usage_report/messages`
- **Web API**: `GET https://claude.ai/api/organizations` → `GET https://claude.ai/api/organizations/{org_id}/usage`
- **Dashboard**: `https://console.anthropic.com/settings/billing`

## 3. OpenAI
- **Auth**: `api`
- **Source Modes**: `auto, api`
- **API Key**: `OPENAI_API_KEY`
- **API Endpoint**: `GET https://api.openai.com/v1/organization/usage`
- **Dashboard**: `https://platform.openai.com/usage`

## 4. MiMo (Xiaomi)
- **Auth**: `web` only
- **Source Modes**: `auto, web`
- **Web Cookies**: `api-platform_serviceToken`, `serviceToken`, `userId` from `.xiaomimimo.com`
- **API Endpoints**:
  - `GET https://platform.xiaomimimo.com/api/v1/balance`
  - `GET https://platform.xiaomimimo.com/api/v1/tokenPlan/detail`
  - `GET https://platform.xiaomimimo.com/api/v1/tokenPlan/usage`
- **Headers**: `Origin: https://platform.xiaomimimo.com`, `Referer: https://platform.xiaomimimo.com/#/console/balance`
- **Dashboard**: `https://platform.xiaomimimo.com/#/console/balance`

## 5. MiniMax
- **Auth**: `web` (cookies + localStorage token), `api`
- **Source Modes**: `auto, web, api`
- **API Key**: `MINIMAX_API_TOKEN`
- **Web Cookies**: `_token`, `HERTZ-SESSION` from `.minimax.io`
- **API Endpoints**:
  - `GET https://api.minimax.io/v1/token_plan/remains` (global)
  - `GET https://api.minimaxi.com/v1/token_plan/remains` (China)
  - `GET https://platform.minimax.io/user-center/payment/coding-plan?cycle_type=3` (HTML)
- **Auth**: `Authorization: Bearer <token>` (from localStorage or API key)
- **Dashboard**: `https://platform.minimax.io/user-center/payment/coding-plan?cycle_type=3`

## 6. Zai
- **Auth**: `api` only
- **API Key**: `Z_AI_API_KEY`
- **API Endpoint**: `GET https://api.z.ai/api/monitor/usage/quota/limit`
- **Auth Header**: `Authorization: Bearer <api_key>`
- **Alt Host**: `open.bigmodel.cn` (China)
- **Response**: `{ success, code, data: { limits: [{ type, unit, number, percentage, nextResetTime }] } }`
- **Dashboard**: `https://z.ai/manage-apikey/coding-plan/personal/my-plan`

## 7. Grok
- **Auth**: `cli`, `web`
- **Source Modes**: `auto, cli, web`
- **CLI Binary**: `grok`
- **Web Cookies**: `sso`, `sso-rw`, `cf_clearance`, `__cf_bm`, `x-userid` from `.grok.com`
- **API Endpoint**: `POST https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig`
- **Protocol**: gRPC-web (Content-Type: `application/grpc-web+proto`)
- **Body**: 5-byte empty frame `[0x00, 0x00, 0x00, 0x00, 0x00]`
- **Headers**: `x-grpc-web: 1`, `x-user-agent: connect-es/2.1.1`
- **Dashboard**: `https://grok.com/?_s=usage`

## 8. Antigravity
- **Auth**: `cli`, `oauth`
- **Source Modes**: `auto, cli, oauth`
- **CLI Binary**: `agy`
- **Local Probe**: Checks localhost ports for running process
- **OAuth**: Credentials from environment or file
- **Dashboard**: N/A

## 9. Cursor
- **Auth**: `web`, `cli`
- **Source Modes**: `auto, cli, web`
- **CLI Binary**: `cursor`
- **Web Cookies**: `__cf_bm` from `.cursor.com`
- **Dashboard**: `https://cursor.com/dashboard?tab=usage`

## 10. DeepSeek
- **Auth**: `api`
- **API Key**: `DEEPSEEK_API_KEY`
- **API Endpoints**:
  - `GET https://api.deepseek.com/user/balance`
  - `GET https://platform.deepseek.com/api/v0/usage/amount`
  - `GET https://platform.deepseek.com/api/v0/usage/cost`
- **Dashboard**: `https://platform.deepseek.com/usage`

## 11. Gemini
- **Auth**: `api`
- **Source Modes**: `auto, api`
- **Dashboard**: `https://gemini.google.com`

## 12. Copilot
- **Auth**: `api`
- **Source Modes**: `auto, api`
- **API Key**: `COPILOT_API_TOKEN`
- **Dashboard**: `https://github.com/settings/copilot`

## 13. Mistral
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: `__cf_bm` from `.mistral.ai`
- **API Endpoints**:
  - `GET https://admin.mistral.ai/organization/usage`
  - `GET https://admin.mistral.ai/organization/billing`
  - `GET https://console.mistral.ai/api-ui/trpc/billing.vibeUsage?batch=1&input=...`
- **Dashboard**: `https://admin.mistral.ai/organization/usage`

## 14. Perplexity
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: `__cf_bm` from `.perplexity.ai`
- **API Endpoint**: `GET https://www.perplexity.ai/rest/billing/credits?version=2.18&source=default`
- **Dashboard**: `https://www.perplexity.ai/account/usage`

## 15. Windsurf
- **Auth**: `web`, `cli`
- **Source Modes**: `auto, web, cli`
- **Web Cookies**: from `.windsurf.com`
- **API Endpoint**: `https://windsurf.com/_backend/exa.seat_management_pb.SeatManagementService/GetPlanStatus`
- **Dashboard**: `https://windsurf.com/subscription/usage`

## 16. Kimi
- **Auth**: `api`, `web`
- **Source Modes**: `auto, api, web`
- **API Key**: `KIMI_AUTH_TOKEN` or `KIMI_API_KEY`
- **API Endpoints**:
  - `POST https://www.kimi.com/apiv2/kimi.gateway.billing.v1.BillingService/GetUsages`
  - `POST https://www.kimi.com/apiv2/kimi.gateway.membership.v2.MembershipService/GetSubscriptionStats`
- **Dashboard**: `https://www.kimi.com/code/console`

## 17. KimiK2
- **Auth**: `api`
- **API Key**: `KIMI_K2_API_KEY`
- **API Endpoint**: `GET https://kimi-k2.ai/api/user/credits`
- **Dashboard**: `https://kimrel.com/my-credits`

## 18. Moonshot
- **Auth**: `api`
- **API Key**: `MOONSHOT_API_KEY`
- **API Endpoint**: `GET https://api.moonshot.cn/v1/users/me/balance`
- **Dashboard**: `https://platform.moonshot.ai/console/account`

## 19. Amp
- **Auth**: `api`, `web`, `cli`
- **Source Modes**: `auto, api, web, cli`
- **CLI Binary**: `amp`
- **API Key**: `AMP_API_KEY`
- **API Endpoint**: `POST https://ampcode.com/api/internal?userDisplayBalanceInfo`
- **Dashboard**: `https://ampcode.com/settings/usage`

## 20. OpenRouter
- **Auth**: `api`
- **API Key**: `OPENROUTER_API_KEY`
- **API Endpoint**: `GET https://openrouter.ai/api/v1/credits`
- **Dashboard**: `https://openrouter.ai/settings/credits`

## 21. ElevenLabs
- **Auth**: `api`
- **API Key**: `ELEVENLABS_API_KEY`
- **API Endpoint**: `GET https://api.elevenlabs.io/v1/user/subscription`
- **Dashboard**: `https://elevenlabs.io/app/developers/usage`

## 22. Groq
- **Auth**: `api`
- **API Key**: `GROQ_API_KEY`
- **Dashboard**: `https://console.groq.com/dashboard/metrics`

## 23. LLM Proxy
- **Auth**: `api`
- **API Key**: `LLM_PROXY_API_KEY`

## 24. LiteLLM
- **Auth**: `api`
- **API Key**: `LITELLM_API_KEY`

## 25. ClawRouter
- **Auth**: `api`
- **API Key**: `CLAWROUTER_API_KEY`
- **Dashboard**: `https://clawrouter.openclaw.ai/dashboard/access`

## 26. CrossModel
- **Auth**: `api`
- **API Key**: `CROSSMODEL_API_KEY`
- **Dashboard**: `https://crossmodel.ai/console/usage`

## 27. Warp
- **Auth**: `api`
- **API Key**: `WARP_API_KEY`
- **API Endpoint**: `POST https://app.warp.dev/graphql/v2?op=GetRequestLimitInfo`
- **Dashboard**: `https://docs.warp.dev/reference/cli/api-keys`

## 28. Venice
- **Auth**: `api`
- **API Key**: `VENICE_API_KEY`
- **API Endpoint**: `GET https://api.venice.ai/api/v1/billing/balance`
- **Dashboard**: `https://venice.ai/settings/api`

## 29. Doubao
- **Auth**: `api`
- **API Key**: `ARK_API_KEY`
- **API Endpoints**:
  - `POST https://ark.cn-beijing.volces.com/api/coding/v3/chat/completions`
  - `GET https://open.volcengineapi.com/?Action=GetCodingPlanUsage&Version=2024-01-01`
- **Dashboard**: `https://console.volcengine.com/ark/...`

## 30. StepFun
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **API Endpoints**:
  - `POST https://platform.stepfun.com/api/step.openapi.devcenter.Dashboard/GetStepPlanStatus`
  - `POST https://platform.stepfun.com/api/step.openapi.devcenter.Dashboard/QueryStepPlanRateLimit`
- **Dashboard**: `https://platform.stepfun.com/plan-usage`

## 31. Poe
- **Auth**: `api`
- **API Key**: `POE_API_KEY`
- **API Endpoints**:
  - `GET https://api.poe.com/usage/current_balance`
  - `GET https://api.poe.com/usage/points_history`
- **Dashboard**: `https://poe.com/api/keys`

## 32. Crof
- **Auth**: `api`
- **API Key**: `CROF_API_KEY`
- **API Endpoint**: `GET https://crof.ai/usage_api/`
- **Dashboard**: `https://crof.ai/dashboard`

## 33. Codebuff
- **Auth**: `api`
- **API Key**: `CODEBUFF_API_KEY`
- **Dashboard**: `https://www.codebuff.com/usage`

## 34. Kilo
- **Auth**: `api`, `cli`
- **Source Modes**: `auto, api, cli`
- **CLI Binary**: `kilo`
- **API Key**: `KILO_API_KEY`
- **API Endpoint**: `GET https://api.kilo.ai/api/profile`
- **Dashboard**: `https://app.kilo.ai/usage`

## 35. Deepgram
- **Auth**: `api`
- **Source Modes**: `auto, api`
- **API Key**: `DEEPGRAM_API_KEY`
- **API Endpoint**: `GET https://api.deepgram.com/v1/projects`
- **Dashboard**: `https://console.deepgram.com/project/`

## 36. Manus
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: from `.manus.im`
- **API Endpoint**: `POST https://api.manus.im/user.v1.UserService/GetAvailableCredits`
- **Dashboard**: `https://manus.im`

## 37. Devin
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: from `.devin.ai`
- **API Endpoint**: `https://app.devin.ai`
- **Dashboard**: `https://app.devin.ai`

## 38. Factory
- **Auth**: `web`, `api`, `cli`
- **Source Modes**: `auto, api, web, cli`
- **Dashboard**: `https://app.factory.ai/settings/billing`

## 39. Augment
- **Auth**: `cli`
- **Source Modes**: `auto, cli`
- **CLI Binary**: `augment`
- **Dashboard**: `https://app.augmentcode.com/account/subscription`

## 40. Kiro
- **Auth**: `cli`
- **Source Modes**: `auto, cli`
- **CLI Binary**: `kiro`
- **Dashboard**: `https://app.kiro.dev/account/usage`

## 41. Command Code
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: from `.commandcode.ai`
- **API Endpoint**: `https://api.commandcode.ai`
- **Dashboard**: `https://commandcode.ai/studio`

## 42. Qoder
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: from `.qoder.com`
- **API Endpoints**:
  - `GET https://qoder.com/api/v2/me/usages/big_model_credits`
  - `GET https://qoder.com.cn/api/v2/me/usages/big_model_credits`
- **Dashboard**: `https://qoder.com/account/usage`

## 43. Sakana
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **API Endpoints**:
  - `GET https://console.sakana.ai/billing`
  - `GET https://console.sakana.ai/billing?tab=payAsYouGo`
- **Dashboard**: `https://console.sakana.ai/billing`

## 44. T3Chat
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **API Endpoint**: `GET https://t3.chat/api/trpc/getCustomerData`
- **Dashboard**: `https://t3.chat/settings/customization`

## 45. Ollama
- **Auth**: `web`, `api`
- **Source Modes**: `auto, web, api`
- **API Key**: `OLLAMA_API_KEY`
- **API Endpoint**: `GET https://ollama.com/api/tags`
- **Dashboard**: `https://ollama.com/settings`

## 46. OpenCode
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: from `.opencode.ai`
- **API Endpoint**: `https://opencode.ai/_server`
- **Dashboard**: `https://opencode.ai`

## 47. OpenCodeGo
- **Auth**: `web`
- **Source Modes**: `auto, web`
- **Web Cookies**: from `.opencode.ai`
- **Dashboard**: `https://opencode.ai`

## 48-60. Simple Providers (Limited/No Fetch)
| Provider | Auth | Env Var | Dashboard |
|----------|------|---------|-----------|
| Abacus | web | - | `https://apps.abacus.ai/chatllm/admin/compute-points-usage` |
| Alibaba | web+api | `SEC_TOKEN` | - |
| AzureOpenAI | api | - | `https://ai.azure.com` |
| Bedrock | api | - | `https://console.aws.amazon.com/bedrock` |
| Chutes | api | - | `https://chutes.ai` |
| JetBrains | cli | - | - |
| LiteLLM | api | `LITELLM_API_KEY` | - |
| Sub2API | api | `API_API_KEY` | - |
| Synthetic | api | - | - |
| VertexAI | oauth | - | `https://console.cloud.google.com/vertex-ai` |
| Wayfinder | api | - | - |
| Zed | api | - | - |
| ZenMux | api | `ZENMUX_MANAGEMENT_API_KEY` | `https://zenmux.ai/platform/management` |

---

## Environment Variables Summary

```
# API Keys
ANTHROPIC_API_KEY          # Claude
OPENAI_API_KEY             # OpenAI
DEEPSEEK_API_KEY           # DeepSeek
MOONSHOT_API_KEY           # Moonshot
MINIMAX_API_TOKEN          # MiniMax
Z_AI_API_KEY               # Zai
GROQ_API_KEY               # Groq
OPENROUTER_API_KEY         # OpenRouter
ELEVENLABS_API_KEY         # ElevenLabs
COPILOT_API_TOKEN          # Copilot
KIMI_AUTH_TOKEN            # Kimi
KIMI_K2_API_KEY            # KimiK2
AMP_API_KEY                # Amp
WARP_API_KEY               # Warp
VENICE_API_KEY             # Venice
ARK_API_KEY                # Doubao
POE_API_KEY                # Poe
CROF_API_KEY               # Crof
CODEBUFF_API_KEY           # Codebuff
KILO_API_KEY               # Kilo
DEEPGRAM_API_KEY           # Deepgram
CLAWROUTER_API_KEY         # ClawRouter
CROSSMODEL_API_KEY         # CrossModel
LLM_PROXY_API_KEY          # LLM Proxy
LITELLM_API_KEY            # LiteLLM
ZENMUX_MANAGEMENT_API_KEY  # ZenMux
OLLAMA_API_KEY             # Ollama
```
